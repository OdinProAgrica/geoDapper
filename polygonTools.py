# https://github.com/hpcc-systems/HPCC-Platform/blob/master/initfiles/examples/embed/python-stream.ecl
# https://hpccsystems.com/bb/viewtopic.php?f=10&t=3613
# https://hpccsystems.com/bb/viewtopic.php?f=23&t=5243
# https://hpccsystems.com/blog/embedding-tensorflow-operations-ecl
# https://hpccsystems.com/bb/viewtopic.php?f=41&t=1509
  
import pyproj 
import shapely
from shapely import wkt, ops
from itertools import combinations
import warnings
import itertools


## Internal Functions ##
def _convert_wkt(poly):
  if isinstance(poly, str):
    return wkt.loads(poly)
  else:
    return poly
#########################


## Single Line Functions ##

def poly_area(poly):
  try:
    poly = _convert_wkt(poly)
    return float(poly.area)
  except shapely.errors.WKTReadingError:
    return 0.0

def wkt_isvalid(poly):  
  try:
    poly = _convert_wkt(poly)
    return poly.is_valid
  except shapely.errors.WKTReadingError:
    return False

    
def poly_isin(poly1, poly2):
  try:
    poly1 = _convert_wkt(poly1)
    poly2 = _convert_wkt(poly2)
    return poly1.contains(poly2)
  except shapely.errors.WKTReadingError:
    return False
  
def poly_intersect(poly1, poly2):
  try:
    poly1 = _convert_wkt(poly1)
    poly2 = _convert_wkt(poly2)
    return poly1.intersects(poly2)
  except shapely.errors.WKTReadingError:
    return False
  
  
def project_polygon(poly, to_proj, from_proj="epsg:4326"):
  """
  Project from one CRS to another. Usually used to make area calcs sensible
  """
  try:
    poly = _convert_wkt(poly)
  except shapely.errors.WKTReadingError:
    return ''    
  
  p1 = pyproj.Proj(init=from_proj)
  p2 = pyproj.Proj(init=to_proj)

  t = lambda x, y: pyproj.transform(p1, p2, x, y)
  poly = ops.transform(t, poly)
  
  return str(poly)
  
   
def overlap_area(polys):
  """
  Remember to project!!!!
  """
  try: 
    union_poly = overlap_polygon(polys)
    return poly_area(union_poly)
  except AttributeError:
    return 0.0
    
    
def overlap_polygon(in_polys):
  polys = []
  for poly in in_polys:
    try:
      polys.append(_convert_wkt(poly))
    except shapely.errors.WKTReadingError:
      warnings.warn("Dropping invalid polygon")
      pass
      
  combinations = itertools.combinations(polys, 2)
  overlaps = [a.intersection(b) for a,b in combinations]
  
  unioned_overlaps = poly_union(overlaps)
  return str(unioned_overlaps)
   
   
def poly_union(in_polys, tol=0.000001):
  """
  Union a list of polygons. Drops invalid polygons at read in
  so CHECK THIS FIRST! `poly_isvalid` will help you here. 

  Parameters
  ----------
  in_polys: list
    polygons to merge in WKT format.
  tol: float
    tolerance to simplify polygons by in the case of an overlapping 
    merge.

  Returns
  -------
  type: string
    String of the resulting WKT.
  """
  combined = shapely.geometry.Polygon()   
  polys = []
  for poly in in_polys:
    try:
      polys.append(_convert_wkt(poly))
    except shapely.errors.WKTReadingError:
      warnings.warn("Dropping invalid polygon")
      pass
  
  for new in polys:
  # first check the new one is valid
    if not new.is_valid:
      warnings.warn("{} is not a valid polygon".format(new.wkt))
      continue
    try:
      combined = combined.union(new)
    except shapely.errors.TopologicalError as e:
      warnings.warn("TopologicalError was raised, trying to simplify both polygons.")
      combined = combined.simplify(tol)
      new = new.simplify(tol)
      combined = combined.union(new)
    except Exception as e:
      warnings.warn("combining {} and {} failed".format(combined.wkt, new.wkt))
      return "Invalid Merged Geometry"
              
    if not combined.is_valid:
      # then check the one we make is valid
      warnings.warn("An invalid polygon was created. Simplification has taken place.")
      combined = combined.simplify(tol)
  return str(combined)
  
###########################################################



## Dataset Wide Functions ##
  
def wkts_are_valid(recs):
  """
  Ensures your WKTs are valid 
  
  Takes an ECL dataset {STRING uid; STRING polygon;}
  Returns an ECL dataset {STRING uid; BOOLEAN is_valid;}
  """
  for rec in recs:  
    yield (rec.uid, wkt_isvalid(rec.polygon))
        
        
def polys_area(recs):  
  """
  Failures will not be returned. Test with polys_is_valid
  first! 
  
  Takes an ECL dataset {STRING uid; STRING polygon;}
  Returns an ECL dataset {STRING uid; REAL area;}
  """
  for rec in recs:
    yield (rec.uid, poly_area(rec.polygon))
 

def polys_arein(recs):
  """
  Failures will not be returned. Test with polys_are_valid
  first! 

  Takes an ECL dataset {STRING uid; STRING polygon; STRING polygon2;}
  Returns an ECL dataset {STRING uid; BOOLEAN is_in;}
  """
  for rec in recs:
    yield (rec.uid, poly_isin(rec.polygon, rec.polygon2))
   
   
def polys_union(recs, tol = 0.000001):      
  """
  Failures will be silently dropped from the merge. Test 
  with polys_is_valid first! 
  
  Takes an ECL dataset {STRING uid; SET OF STRING polygons;}
  Returns an ECL dataset {STRING uid; STRING polygon;}
  """
  
  for rec in recs:
    yield (rec.uid, poly_union(rec.polygons, tol))
    
   
def overlap_areas(recs):      
  """
  Failures will be silently dropped from the merge. Test 
  with polys_is_valid first! 
  
  Takes an ECL dataset {STRING uid; SET OF STRING polygons;}
  Returns an ECL dataset {STRING uid; REAL overlap;}
  """
  
  for rec in recs:
    yield (rec.uid, overlap_area(rec.polygons))
    
    
def overlap_polygons(recs):      
  """
  Failures will be silently dropped from the merge. Test 
  with polys_is_valid first! 
  
  Takes an ECL dataset {STRING uid; SET OF STRING polygons;}
  Returns an ECL dataset {STRING uid; STRING polygon;}
  """
  
  for rec in recs:
    yield (rec.uid, overlap_polygon(rec.polygons))    
    
    
def polys_intersect(recs):
  """
  Takes an ECL dataset {STRING uid; STRING polygon; STRING polygon2;}
  Returns an ECL dataset {STRING uid; BOOLEAN intersects;}
  """
  for rec in recs:
    yield(rec.uid, poly_intersect(rec.polygon, rec.polygon2))
    
    
def project_polygons(recs, to_proj, from_proj="epsg:4326"):      
  """
  Failures will be silently dropped from the merge. Test 
  with polys_is_valid first! 
  
  Takes an ECL dataset {STRING uid; STRING polygon;}
  Returns an ECL dataset {STRING uid; STRING polygon;}
  """
  
  for rec in recs:
    yield (rec.uid, project_polygon(rec.polygon, to_proj, from_proj))
###########################################################