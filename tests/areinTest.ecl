IMPORT $.^.polygontools as pt;
//IMPORT dapper.transformtools as tt;


//polys_arein
are_in_input1 := DATASET([{'a', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))' , 'POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))'},
																									 {'z', 'POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))' , 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))'},
																									 {'b', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))' , 'POINT(30 30)'},
																									 {'c', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))' , 'POINT(30 30)'},
																									 {'d', 'POLYGON((20 20, 10 15, 15 20, 30 30))'							 , 'POINT(30 30)'}, //Invalid
																									 {'e', 'POLYGON((30 30, 20 25, 25 30, 30 30))'						 	, 'POINT(30 30)'},
																									 {'f', 'POLYGON((20 20, 30 45, 25 30, 40 40))'							 , 'POINT(30 30)'}], //Invalid
																									 {STRING uid; STRING inner; STRING outer;});
																																	
result_arein1 := pt.polys_arein(are_in_input1);
result_arein1;

/* 
   // TODO: NEED TO MAKE ALL OF THESE ASSERTIONS. FUN!!
   // TODO: We need to catch object is not callable errors resulting from outputting a dataset before handing to python.
   
   testPolygon1_valid   := 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))';
   testPolygon2_valid   := 'POLYGON((30 30, 0  30, 0  0 , 30 0 , 30 30))';
   testPolygon3_valid   := 'POLYGON((80 80, 70 80, 70 70, 80 70, 80 80))';
   testPolygon4_valid   := 'POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))';
   testPolygon5_valid   := 'POLYGON((38 36, 31 36, 31 32, 38 32, 38 36))';
   testPolygon1_invalid := 'POLYGON((50 50, 10 45, 45 30))';
   polygon_1_2_overlap  := 'POLYGON ((30 20, 20 20, 20 30, 30 30, 30 20))';
   polygon_1_2_merge    := 'POLYGON ((20 30, 20 40, 40 40, 40 20, 30 20, 30 0, 0 0, 0 30, 20 30))';
   polygon_1_3_merge    := 'MULTIPOLYGON (((40 40, 20 40, 20 20, 40 20, 40 40)), ((80 80, 70 80, 70 70, 80 70, 80 80)))';
   point_in_poly1 					 := 'POINT(30 30)';
   point_not_in_poly1 	 := 'POINT(10 20)';
   testPolygon1_proj    := 'POLYGON ((-5859217.665004583 19079552.86261966, -5655022.66907411 21666408.13354161, -9437263.369419977 23486756.31298198, -10159419.07202138 17973599.55362881, -5859217.665004583 19079552.86261966))';
   										
   //wkt_isvalid
   ASSERT(pt.wkt_isvalid(testPolygon1_valid), FAIL);
   ASSERT(pt.wkt_isvalid(testPolygon2_valid), FAIL);
   ASSERT(NOT pt.wkt_isvalid(testPolygon1_invalid), FAIL);
   
   //poly_isin
   ASSERT(pt.poly_isin(point_in_poly1, testPolygon1_valid), FAIL); //Point in polygon
   ASSERT(NOT pt.poly_isin(point_not_in_poly1, testPolygon1_valid), FAIL); //Point not in polygon
   ASSERT(pt.poly_isin(testPolygon4_valid, testPolygon1_valid), FAIL); //one poly in another
   ASSERT(NOT pt.poly_isin(testPolygon2_valid, testPolygon1_valid), FAIL); //slight overlap
   ASSERT(NOT pt.poly_isin(testPolygon4_valid, testPolygon3_valid), FAIL); //not in
   
   //project_polygon
   ASSERT(pt.project_polygon(testPolygon1_valid, 'epsg:28351') = testPolygon1_proj, FAIL);
   ASSERT(pt.project_polygon(testPolygon1_invalid, 'epsg:28351') = '', FAIL);
   
   //poly_area
   ASSERT(pt.poly_area(testPolygon1_valid) = 400, FAIL);
   ASSERT(pt.poly_area(testPolygon1_invalid) = 0, FAIL);
   
   //overlap_area
   ASSERT(pt.overlap_area([testPolygon1_valid, testPolygon2_valid]) = 100, FAIL);
   ASSERT(pt.overlap_area([testPolygon1_valid, testPolygon1_invalid]) = 0, FAIL);
   ASSERT(pt.overlap_area([testPolygon3_valid, testPolygon1_valid]) = 0, FAIL);
   
   //overlap_polygon
   ASSERT(pt.overlap_polygon([testPolygon1_valid, testPolygon2_valid]) = polygon_1_2_overlap, FAIL);
   ASSERT(pt.overlap_polygon([testPolygon1_valid, testPolygon1_invalid]) = '', FAIL);
   ASSERT(pt.overlap_polygon([testPolygon1_valid, testPolygon3_valid]) = 'GEOMETRYCOLLECTION EMPTY', FAIL);
   
   //poly_union
   ASSERT(pt.poly_union([testPolygon1_valid, testPolygon2_valid]) = polygon_1_2_merge, FAIL);
   ASSERT(pt.poly_union([testPolygon1_valid, testPolygon1_invalid]) = '', FAIL);
   ASSERT(pt.poly_union([testPolygon1_valid, testPolygon3_valid]) = polygon_1_3_merge, FAIL);
   
   //poly_corners
   poly_1_corners := [20.0, 20.0, 40.0, 40.0];
   poly_5_corners := [31.0, 32.0, 38.0, 36.0];
   found_1_corners := pt.poly_corners(testPolygon1_valid);
   found_5_corners := pt.poly_corners(testPolygon5_valid);
   
   ASSERT(pt.poly_corners(testPolygon1_invalid)[1] = 0, FAIL);
   
   ASSERT(poly_1_corners[1] = found_1_corners[1], FAIL);
   ASSERT(poly_1_corners[2] = found_1_corners[2], FAIL);
   ASSERT(poly_1_corners[3] = found_1_corners[3], FAIL);
   ASSERT(poly_1_corners[4] = found_1_corners[4], FAIL);
   
   ASSERT(poly_5_corners[1] = found_5_corners[1], FAIL);
   ASSERT(poly_5_corners[2] = found_5_corners[2], FAIL);
   ASSERT(poly_5_corners[3] = found_5_corners[3], FAIL);
   ASSERT(poly_5_corners[4] = found_5_corners[4], FAIL);
   
   //poly_centroid
   poly_1_centroid := 'POINT (30 30)';
   ASSERT(pt.poly_centroid(testPolygon1_valid) = poly_1_centroid	, FAIL);
   ASSERT(pt.poly_centroid(testPolygon1_invalid) = ''	, FAIL);
   
   
   // DATASET wide
   geoSet := DATASET([{'a', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))', 'POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))'},
                      {'a1', 'POLYGON((35 35, 30 35, 30 30, 35 30, 35 35))', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))'},
                      {'b', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))', 'POINT(30 30)'},
                      {'c', 'POLYGON((40 40, 20 40, 20 20, 40 20, 40 40))', 'POINT(30 30)'},
                      {'d', 'POLYGON((20 20, 10 15, 15 20, 30 30))'							, 'POINT(30 30)'}, //Invalid
                      {'e', 'POLYGON((30 30, 20 25, 25 30, 30 30))'							, 'POINT(30 30)'},
                      {'f', 'POLYGON((20 20, 30 45, 25 30, 40 40))'							, 'POINT(30 30)'}], //Invalid
                      {STRING uid; STRING polygon; STRING polygon2;});
   									 
   //wkts_are_valid     
   invalid_results := DATASET([{'a', TRUE},
   																											 {'a1', TRUE},
   																											 {'b', TRUE},
   																											 {'c', TRUE},
   																											 {'d', FALSE},
   																											 {'e', TRUE},
   																											 {'f', FALSE}],
   																												pt.validoutrec);
   																												
//   result_are_valid := pt.wkts_are_valid(tt.select(geoSet, 'uid, polygon'));
//   joined_are_valid := JOIN(result_are_valid, invalid_results, LEFT.uid = RIGHT.uid AND LEFT.is_valid = RIGHT.is_valid, FULL ONLY);
//   ASSERT(COUNT(joined_are_valid) = 0, FAIL);
   
   //polys_area
//   area_results := DATASET([{'a', 400 },
   																								 {'a1', 25 },
   																								 {'b', 400 },
   																								 {'c', 400 },
   																								 {'d', 0   },
   																								 {'e', 12.5},
   																								 {'f', 0   }],
   																								 {STRING uid; REAL area;});
   
//   result_area := pt.polys_area(tt.select(geoSet, 'uid, polygon'));
//   joined_area := JOIN(result_area, area_results, LEFT.uid = RIGHT.uid AND LEFT.area = RIGHT.area, FULL ONLY);
//   ASSERT(COUNT(joined_area) = 0, FAIL);
   
   
*/

  
