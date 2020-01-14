IMPORT $.^.polygontools as pt;
IMPORT dapper.transformtools as tt;

// DATASET wide
geoSet := DATASET([{'a', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))', 'POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))'},
                   {'a1','POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))'},
                   {'b', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))', 'POINT(30 30)'},
                   {'c', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))', 'POINT(30 30)'},
                   {'d', 'POLYGON((20 20, 10 15, 15 20, 30 30))'							, 'POINT(30 30)'}, //Invalid
                   {'e', 'POLYGON((30 30, 20 25, 25 30, 30 30))'							, 'POINT(-30 -30)'},
                   {'f', 'POLYGON((20 20, 30 45, 25 30, 40 40))'							, 'POINT(30 30)'}], //Invalid
                   {STRING uid; STRING polygon; STRING polygon2;});
									 
//wkts_are_valid     
invalid_results := DATASET([{'a',  TRUE},
																											 {'a1', TRUE},
																											 {'b',  TRUE},
																											 {'c',  TRUE },
																											 {'d',  FALSE},
																											 {'e',  TRUE},
																											 {'f',  FALSE}],
																												pt.validoutrec);
																												
																												
result_are_valid := pt.wkts_are_valid(tt.select(geoSet, 'uid, polygon'));
joined_are_valid := JOIN(result_are_valid, invalid_results, LEFT.uid = RIGHT.uid AND LEFT.is_valid = RIGHT.is_valid, FULL ONLY);
ASSERT(COUNT(joined_are_valid) = 0, FAIL);

//polys_area
area_results := DATASET([{'a', 400 },
																								 {'a1', 25 },
																								 {'b', 400 },
																								 {'c', 400 },
																								 {'d', 0   },
																								 {'e', 12.5},
																								 {'f', 0   }],
																								 {STRING uid; REAL area;});

result_area := pt.polys_area(tt.select(geoSet, 'uid, polygon'));
joined_area := JOIN(result_area, area_results, LEFT.uid = RIGHT.uid AND LEFT.area = RIGHT.area, FULL ONLY);
ASSERT(COUNT(joined_area) = 0, FAIL);


//project_polygons
project_expected := 
	DATASET([
			{'a' , 'POLYGON ((-5859217.665004583 19079552.86261966, -5655022.66907411 21666408.13354161, -9437263.369419977 23486756.31298198, -10159419.07202138 17973599.55362881, -5859217.665004583 19079552.86261966))'},
			{'a1', 'POLYGON ((-6845491.3561668 19681541.9687141, -6833601.966351711 20472006.25887704, -7852930.164422889 20570609.61280089, -7869297.845909575 19615554.10688185, -6845491.3561668 19681541.9687141))'},
			{'b' , 'POLYGON ((-5859217.665004583 19079552.86261966, -5655022.66907411 21666408.13354161, -9437263.369419977 23486756.31298198, -10159419.07202138 17973599.55362881, -5859217.665004583 19079552.86261966))'},
			{'c' , 'POLYGON ((-5859217.665004583 19079552.86261966, -5655022.66907411 21666408.13354161, -9437263.369419977 23486756.31298198, -10159419.07202138 17973599.55362881, -5859217.665004583 19079552.86261966))'},
			{'d' ,''},
			{'e' ,'POLYGON ((-7852930.164422889 20570609.61280089, -8348321.312388361 22842012.01571515, -7677576.695425874 21497425.5209452, -7852930.164422889 20570609.61280089))'},
			{'f' ,''}], 
			{STRING uid; STRING polygon;});

reusult_project := pt.project_polygons(tt.select(geoSet, 'uid, polygon'), 'epsg:28351');
joined_project  := JOIN(reusult_project, project_expected, LEFT.uid = RIGHT.uid AND LEFT.polygon = RIGHT.polygon, FULL ONLY);
ASSERT(COUNT(joined_project) = 0, FAIL);

//polys_intersect
intersect_expected := 
	DATASET([
			{'a',	 true },
			{'a1',	true },
			{'b',	 true },
			{'c',	 true },
			{'d',	 false},
			{'e',	 false },
			{'f',	 false}], 
			{STRING uid; BOOLEAN intersects;});


reusult_intersect := pt.polys_intersect(tt.select(geoSet, 'uid, polygon, polygon2'));
joined_interect   := JOIN(reusult_intersect, intersect_expected, LEFT.uid = RIGHT.uid AND LEFT.intersects = RIGHT.intersects, FULL ONLY);
ASSERT(COUNT(joined_interect) = 0, FAIL);

//polys_corners
corners_expected := 
	DATASET([
				{'a',	 20.0,	20.0,	40.0,	40.0},
				{'a1',	30.0,	30.0,	35.0,	35.0},
				{'b',	 20.0,	20.0,	40.0,	40.0},
				{'c',	 20.0,	20.0,	40.0,	40.0},
				{'d',	 0.0	,  0.0,	 0.0,	 0.0},
				{'e',	 20.0,	25.0,	30.0,	30.0},
				{'f',	 0.0	,  0.0,	 0.0,	 0.0}], 
				{STRING uid; REAL lon_min; REAL lat_min; REAL lon_max; REAL lat_max;});
				
corners_result := pt.polys_corners(tt.select(geoSet, 'uid, polygon'));
joined_corners := JOIN(corners_result, corners_expected, 
																						LEFT.uid = RIGHT.uid AND 
																						LEFT.lon_min = RIGHT.lon_min AND 
																						LEFT.lat_min = RIGHT.lat_min AND 
																						LEFT.lon_max = RIGHT.lon_max AND 
																						LEFT.lat_max = RIGHT.lat_max, 
																						FULL ONLY);
ASSERT(COUNT(joined_corners) = 0, FAIL);
				
//polys_centroids
centroids_expected := 
	DATASET([
			{'a',	 'POINT (30 30)'},
			{'a1',	'POINT (32.5 32.5)'},
			{'b',	 'POINT (30 30)'},
			{'c',	 'POINT (30 30)'},
			{'d',	 ''},
			{'e',	 'POINT (25 28.33333333333334)'},
			{'f',	 ''}], 
			{STRING uid; STRING centroid;});
			
centroids_result := pt.polys_centroids(tt.select(geoSet, 'uid, polygon'));
joined_centroids := JOIN(centroids_result, centroids_expected, LEFT.uid = RIGHT.uid AND LEFT.centroid = RIGHT.centroid, FULL ONLY);
ASSERT(COUNT(joined_centroids) = 0, FAIL);

// tests for SET OF STRINGS in DATASETS  
// addSet := 
  // DATASET([{'a', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))'},
										 // {'a','POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))'},
										 // {'b', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))'},
										 // {'b', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))'},
										 // {'b', 'POLYGON((20 20, 10 15, 15 20, 30 30))'							}, //Invalid
										 // {'b', 'POLYGON((30 30, 20 25, 25 30, 30 30))'							},
										 // {'c', 'POLYGON((20 20, 30 45, 25 30, 40 40))'							}], //Invalid
										 // {STRING uid; STRING polygon;});
// stackedPolys := pt.polyrollup(addSet, uid, polygons);
// stackedPolys;
// mergedData   := tt.select(stackedPolys, 'uid, polygons');
																 
// pt.polys_union(mergedData);
// pt.overlap_areas(mergedData);
// pt.overlap_polygons(mergedData);
       


//polys_arein
are_in_input1 := DATASET([{'a', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))' , 'POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))'}, //Inner and outer flipped
																									 {'z', 'POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))' , 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))'},
																									 {'b', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))' , 'POINT(30 30)'},
																									 {'c', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))' , 'POINT(30 30)'},
																									 {'d', 'POLYGON((20 20, 10 15, 15 20, 30 30))'							 , 'POINT(30 30)'}, //Invalid
																									 {'e', 'POLYGON((30 30, 20 25, 25 30, 30 30))'						 	, 'POINT(30 30)'},
																									 {'f', 'POLYGON((20 20, 30 45, 25 30, 40 40))'							 , 'POINT(30 30)'}], //Invalid
																									 {STRING uid; STRING inner; STRING outer;});
																																	
result_arein1 := pt.polys_arein(are_in_input1);
result_arein1;
