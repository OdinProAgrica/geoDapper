IMPORT $.polygontools as pt;
IMPORT dapper.transformtools as tt;


// TODO: NEED TO MAKE ALL OF THESE ASSERTIONS. FUN!!
// TODO: We need to catch object is not callable errors resulting from outputting a dataset before handing to python.


// Tests for single line transforms
pt.wkt_isvalid('POLYGON((40 40, 20 45, 45 30, 40 40))');
pt.poly_isin('POLYGON((40 40, 20 45, 45 30, 40 40))', 'POINT(10 20)');
pt.poly_isin('POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))');
pt.project_polygon('POLYGON((40 40, 20 45, 45 30, 40 40))', 'epsg:28351');
pt.poly_area('POLYGON((40 40, 20 45, 45 30, 40 40))');
pt.overlap_area(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))']);
pt.overlap_polygon(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))']);
pt.poly_union(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))']);

geoSet := DATASET([{'a', 'POLYGON((40 40, 20 45, 45 30, 40 40))', 'POINT(35 39)'},
																	  {'a', 'POLYGON((50 50, 30 55, 55 40, 50 50))', 'POINT(30 30)'},
																	  {'a', 'POLYGON((60 60, 40 65, 65 50, 60 60))', 'POINT(30 30)'},
																	  {'b', 'POLYGON((10 10, 20 35, 15 20, 10 10))', 'POINT(30 30)'},
																	  {'c', 'POLYGON((20 20, 10 15, 15 20, 30 30))', 'POINT(30 30)'},
																	  {'d', 'POLYGON((30 30, 20 25, 25 30, 30 30))', 'POINT(30 30)'},
																	  {'b', 'POLYGON((20 20, 30 45, 25 30, 40 40))', 'POINT(30 30)'}], 
																	  {STRING uid; STRING polygon; STRING polygon2;});
																		
pt.wkts_are_valid(tt.select(geoSet, 'uid, polygon'));
pt.polys_area(tt.select(geoSet, 'uid, polygon'));
pt.polys_arein(tt.select(geoSet, 'uid, polygon, polygon2'));
pt.project_polygons(tt.select(geoSet, 'uid, polygon'), 'epsg:4326');
pt.polys_intersect(tt.select(geoSet, 'uid, polygon, polygon2'));

// tests for SET OF STRINGS in DATASETS  
addSet := PROJECT(geoSet, TRANSFORM({STRING uid; STRING polygon; SET OF STRING polygons;}, SELF.polygons := [LEFT.polygon]; SELF := LEFT;));

stackedPolys := 
		ROLLUP(tt.arrange(addSet, 'uid'), 
					LEFT.uid = RIGHT.uid, 
					TRANSFORM(RECORDOF(addSet),
															SELF.polygons := LEFT.polygons + RIGHT.polygons;				
															SELF := RIGHT;));
mergedData := tt.select(stackedPolys, 'uid, polygons');
																	
pt.polys_union(mergedData);
pt.overlap_areas(mergedData);
pt.overlap_polygons(mergedData);



  