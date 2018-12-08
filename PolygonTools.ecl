IMPORT python3;

// THIS MODULE EXPORTS PYTHON FUNCTIONS FOR HANDLING AREAS.
// It requires that you have polygonTools.py installed in 
// the correct place for each node, that the python3 
// plugin is installed AND that you've updated
// /etc/HPCCSystems/environment.conf
// to use python3 (additionalPlugins=python3) 

// YOU CAN'T IN ANY WAY OUTPUT YOUR DATA BEFORE HANDING IT TO PYTHON, 
// IT GIVES YOU AN OBJECT NOT CALLABLE ERROR. THIS INCLUDES TO_THOR 
// AND PERSISTS. PERSISTS!!!!

EXPORT PolygonTools := MODULE
  // SHARED module_location := './polygonTools.';
  SHARED module_location := '/opt/HPCCSystems/scripts/bin/polygonTools.';

  // Dataset Operations ///////////////////////////////////////////////////////
  // These take in a whole dataset and return a whole dataset. More basic    //
  // calls for transforms and join logic are also available.                 //
  //                                                                         //
  // WARNING: Failures due to faulty polygons my cause a no return on the    //
  // output dataset. You should check your polygons with polys_are_valid     //
  // before any operations. Python in HPCC has a habit of failing silently.  //
  /////////////////////////////////////////////////////////////////////////////

  //wkts_are_valid
  //eg: wkts_are_valid(validIn)
  EXPORT validInRec := {STRING uid; STRING polygon;};
  EXPORT ValidOutRec := {STRING uid; BOOLEAN is_valid;};
  EXPORT DATASET(ValidOutRec) wkts_are_valid(DATASET(validInRec) recs) := IMPORT(python3, module_location + 'wkts_are_valid');

  //polys_area
  //eg: polys_area(areaIn)
  EXPORT areaInRec := {STRING uid; STRING polygon;};
  EXPORT areaOutRec := {STRING uid; REAL area;};
  EXPORT DATASET(areaOutRec) polys_area (DATASET(areaInRec) recs) := IMPORT(python3, module_location + 'polys_area');

  // polys_arein - is one point/line/polygon within a polygon?
  //eg: polys_arein(containsIn)
  EXPORT containsInRec := {STRING uid; STRING polygon; STRING polygon2;};
  EXPORT containsOutRec := {STRING uid; BOOLEAN is_in;};
  EXPORT DATASET(containsOutRec) polys_arein (DATASET(containsInRec) recs):= IMPORT(python3, module_location + 'polys_arein');

  // polys_union
  //eg: polys_union(unionIn, tol = 0.000001)
  EXPORT unionInRec := {STRING uid; SET OF STRING polygons;};
  EXPORT unionOutRec := {STRING uid; STRING polygon;};
  EXPORT DATASET(unionOutRec) polys_union(DATASET(unionInRec) recs, REAL tol = 0.000001) := IMPORT(python3, module_location + 'polys_union');

  //polys_intersect
  //eg: polys_intersect(intersectIn)
  EXPORT intersectInRec := {STRING uid; STRING polygon; STRING polygon2;};
  EXPORT intersectOutRec := {STRING uid; BOOLEAN intersects;};
  EXPORT DATASET(intersectOutRec) polys_intersect(DATASET(intersectInRec) recs) := IMPORT(python3, module_location + 'polys_intersect');

  //overlap_areas
  //eg: overlap_areas(overlapAreaIn)
  EXPORT overlapAreaInRec := {STRING uid; SET OF STRING polygons;};
  EXPORT overlapAreaOutRec := {STRING uid; REAL overlap;};
  EXPORT DATASET(overlapAreaOutRec) overlap_areas(DATASET(overlapAreaInRec) recs) := IMPORT(python3, module_location + 'overlap_areas');

  //overlap_polygons
  //eg: overlap_polygons(overlapAreaIn)
  EXPORT overlapPolygonInRec := {STRING uid; SET OF STRING polygons;};
  EXPORT overlapPolygonOutRec := {STRING uid; STRING polygon;};
  EXPORT DATASET(overlapPolygonOutRec) overlap_polygons(DATASET(overlapPolygonInRec) recs) := IMPORT(python3, module_location + 'overlap_polygons');

  //project_polygons
  //eg: project_polygons(projectIn, 'epsg:28351', from_proj='epsg:4326')
  EXPORT projectInRec := {STRING uid; STRING polygon;};
  EXPORT projectOutRec := {STRING uid; STRING polygon;};
  EXPORT DATASET(projectOutRec) project_polygons(DATASET(projectInRec) recs, STRING to_proj, STRING from_proj='epsg:4326') := IMPORT(python3, module_location + 'project_polygons');



  // Transform Operations /////////////////////////////////////////////////////
  // These operations can be applied as part of a transform, for example:    //
  // SELF.area := poly_area(LEFT.polygon)                                    //
  // This also means you could use them as part of a join condition:         //
  // poly_isin(LEFT.poly, RIGHT.poly)                                        //
  // but use with caution, the dataset wide operations are much more         //
  // efficient. You definitely want to use other join conditions to slim     //
  // down the number of python calls you have to make.                       //
  //                                                                         //
  // WARNING: Failures due to faulty polygons my cause a no return on the    //
  // output dataset. You should check your polygons with polys_are_valid     //
  //before any operations. Python in HPCC has a habit of failing silently.   //
  /////////////////////////////////////////////////////////////////////////////

  //wkt_isvalid
  //eg: wkt_isvalid('POLYGON((40 40, 20 45, 45 30, 40 40))')
  EXPORT BOOLEAN wkt_isvalid(STRING poly) := IMPORT(python3, module_location + 'wkt_isvalid');

  //poly_isin
  //eg: poly_isin('POLYGON((40 40, 20 45, 45 30, 40 40))', 'POINT(10 20)')
  EXPORT BOOLEAN poly_isin(STRING inner, STRING outer) := IMPORT(python3, module_location + 'poly_isin');

  //poly_intersect
  //eg: poly_isin('POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))')
  EXPORT BOOLEAN poly_intersect(STRING poly1, STRING poly2) := IMPORT(python3, module_location + 'poly_intersect');

  //project_polygon
  //eg: project_polygon('POLYGON((40 40, 20 45, 45 30, 40 40))', 'epsg:28351')
  EXPORT STRING project_polygon(STRING poly, STRING to_proj, STRING from_proj='epsg:4326') := IMPORT(python3, module_location + 'project_polygon');

  //poly_area - Remember to project first!!!
  //eg: poly_area('POLYGON((40 40, 20 45, 45 30, 40 40))')
  EXPORT REAL poly_area(STRING poly_in) := IMPORT(python3, module_location + 'poly_area');

  //overlap_area - Remember to project first!!!!
  //eg: overlap_area(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))'])
  EXPORT REAL overlap_area(SET OF STRING polys) := IMPORT(python3, module_location + 'overlap_area');

  //overlap_polygon
  //eg: overlap_polygon(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))'])
  EXPORT STRING overlap_polygon(SET OF STRING polys) := IMPORT(python3, module_location + 'overlap_polygon');

  //poly_union
  //eg: poly_union(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))'])
  EXPORT STRING poly_union(SET OF STRING in_polys, REAL tol=0.000001) := IMPORT(python3, module_location + 'poly_union');

END;





