# https://github.com/hpcc-systems/HPCC-Platform/blob/master/initfiles/examples/embed/python-stream.ecl
# https://hpccsystems.com/bb/viewtopic.php?f=10&t=3613
# https://hpccsystems.com/bb/viewtopic.php?f=23&t=5243
# https://hpccsystems.com/blog/embedding-tensorflow-operations-ecl
# https://hpccsystems.com/bb/viewtopic.php?f=41&t=1509
  
import pyproj 
import shapely
from shapely import wkt, ops
import warnings
import itertools
from functools import wraps
import traceback


# Internal Functions #
def _fail_as(fail_as):
    def wrapper(f):
        @wraps(f)
        def func_wrapper(*args, **kwargs):
            return _fail_nicely(f, fail_as, args, kwargs)
        return func_wrapper
    return wrapper

# TODO test
def _convert_wkt(poly):
    if isinstance(poly, str):
        return wkt.loads(poly)
    else:
        return poly


def _fail_nicely(f, to_return, args, kwargs):
    try:
        return f(*args, **kwargs)
    except Exception:
        tb = traceback.format_exc()
        warnings.warn(tb)
        return to_return




#########################


# Single Line Functions #
@_fail_as(0.0)
def poly_area(poly):
    poly = _convert_wkt(poly)
    return float(poly.area)


@_fail_as(False)
def wkt_isvalid(poly):
    poly = _convert_wkt(poly)
    return poly.is_valid


@_fail_as(False)
def poly_isin(inner, outer):
    inner = _convert_wkt(inner)
    outer = _convert_wkt(outer)
    return outer.contains(inner)


@_fail_as(False)
def poly_intersect(poly1, poly2):
    poly1 = _convert_wkt(poly1)
    poly2 = _convert_wkt(poly2)
    return poly1.intersects(poly2)


@_fail_as("")
def project_polygon(poly, to_proj, from_proj="epsg:4326"):
    """
    Project from one CRS to another. Usually used to make area calcs sensible
    """

    poly = _convert_wkt(poly)
  
    p1 = pyproj.Proj(init=from_proj)
    p2 = pyproj.Proj(init=to_proj)

    t = lambda x, y: pyproj.transform(p1, p2, x, y)
    poly = ops.transform(t, poly)
  
    return poly.wkt


#todo test
def overlap_area(polys):
  """
  Remember to project!!!!
  """
  try: 
    union_poly = overlap_polygon(polys)
    return poly_area(union_poly)
  except AttributeError:
    return 0.0


# todo test
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


@_fail_as("")
def combine_polygons(poly_1, poly_2, tol=0.000001):
    try:
        p1 = _convert_wkt(poly_1)
    except shapely.errors.WKTReadingError:

        p1 = shapely.geometry.Polygon()
    else:
        if not p1.is_valid:
            p1 = p1.simplify(tol)
    try:
        p2 = _convert_wkt(poly_2)
    except shapely.errors.WKTReadingError:
        p2 = shapely.geometry.Polygon()
    else:
        if not p2.is_valid:
            p2 = p2.simplify(tol)

    assert p1.is_valid
    assert p2.is_valid

    try:
        p = p1.union(p2)
    except shapely.errors.TopologicalError:
        p1 = p1.simplify(tol)
        p2 = p2.simplify(tol)
        p = combine_polygons(p1, p2, tol)

    if not p.is_valid:
        p = p.simplify(tol)
    assert p.is_valid
    return p.wkt


# todo test
@_fail_as("")
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
    combined = shapely.geometry.Polygon().wkt
    for new in in_polys:
        combined = combine_polygons(combined, new, tol) or combined
    return combined
  
###########################################################



## Dataset Wide Functions ##
# todo test
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
 
#todo test
def polys_arein(recs):
  """
  Failures will not be returned. Test with polys_are_valid
  first! 

  Takes an ECL dataset {STRING uid; STRING polygon; STRING polygon2;}
  Returns an ECL dataset {STRING uid; BOOLEAN is_in;}
  """
  for rec in recs:
    yield (rec.uid, poly_isin(rec.polygon, rec.polygon2))

  # todo test
def polys_union(recs, tol = 0.000001):      
  """
  Failures will be silently dropped from the merge. Test 
  with polys_is_valid first! 
  
  Takes an ECL dataset {STRING uid; SET OF STRING polygons;}
  Returns an ECL dataset {STRING uid; STRING polygon;}
  """
  
  for rec in recs:
    yield (rec.uid, poly_union(rec.polygons, tol))

  # todo test
def overlap_areas(recs):      
  """
  Failures will be silently dropped from the merge. Test 
  with polys_is_valid first! 
  
  Takes an ECL dataset {STRING uid; SET OF STRING polygons;}
  Returns an ECL dataset {STRING uid; REAL overlap;}
  """
  
  for rec in recs:
    yield (rec.uid, overlap_area(rec.polygons))

    # todo test
def overlap_polygons(recs):      
  """
  Failures will be silently dropped from the merge. Test 
  with polys_is_valid first! 
  
  Takes an ECL dataset {STRING uid; SET OF STRING polygons;}
  Returns an ECL dataset {STRING uid; STRING polygon;}
  """
  
  for rec in recs:
    yield (rec.uid, overlap_polygon(rec.polygons))

    # todo test
def polys_intersect(recs):
  """
  Failures will be silently dropped from the merge. Test 
  with polys_is_valid first! 
  
  Takes an ECL dataset {STRING uid; STRING polygon; STRING polygon2;}
  Returns an ECL dataset {STRING uid; BOOLEAN intersects;}
  """
  for rec in recs:
    yield(rec.uid, poly_intersect(rec.polygon, rec.polygon2))

  # todo test
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