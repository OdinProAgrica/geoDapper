IMPORT $.^.polygontools as pt;
IMPORT dapper.transformtools as tt;

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


/* 
*/
