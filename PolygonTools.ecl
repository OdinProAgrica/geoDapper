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
	
		//Are Valid:
	 EXPORT wkts_arevalid(validDS, polycol) := FUNCTIONMACRO
			LOCAL outrec := {RECORDOF(validDS); BOOLEAN valid;};
			LOCAL outDS  := PROJECT(validDS, TRANSFORM(outrec, SELF.valid := pt.poly_isvalid(LEFT.polycol); SELF := LEFT;));							
			RETURN outDS;
		ENDMACRO;
		
		//Are in:
	 EXPORT polys_arein(areinDS, innercol, outercol) := FUNCTIONMACRO
			LOCAL outrec := {RECORDOF(areinDS); BOOLEAN isin;};
			LOCAL outDS  := PROJECT(areinDS, TRANSFORM(outrec, SELF.isin := pt.poly_isin(LEFT.innercol, LEFT.outercol); SELF := LEFT;));							
			RETURN outDS;
		ENDMACRO;

		//intersect:
	 EXPORT polys_intersect(intersectDS, polycol1, polycol2) := FUNCTIONMACRO
			LOCAL outrec := {RECORDOF(intersectDS); BOOLEAN intersect;};
			LOCAL outDS  := PROJECT(intersectDS, TRANSFORM(outrec, SELF.intersect := pt.poly_intersect(LEFT.polycol1, LEFT.polycol2); SELF := LEFT;));							
			RETURN outDS;
		ENDMACRO;
		
		//project:
	 EXPORT polys_project(projDS, polycol, to_proj, from_proj='epsg:4326') := FUNCTIONMACRO
			LOCAL outDS  := PROJECT(projDS, TRANSFORM(RECORDOF(projDS), SELF.valid := pt.poly_project(LEFT.polycol, to_proj, from_proj); SELF := LEFT;));							
			RETURN outDS;
		ENDMACRO;
				
		//Area:
	 EXPORT polys_area(areaDS, polycol) := FUNCTIONMACRO
			LOCAL outrec := {RECORDOF(areaDS); REAL area;};
			LOCAL outDS  := PROJECT(areaDS, TRANSFORM(outrec, SELF.area := pt.poly_area(LEFT.polycol); SELF := LEFT;));							
			RETURN outDS;
		ENDMACRO;		
		
		//overlap_area: NAME!!! SHOULD NOT ROIP OLD VALUES
	 EXPORT overlap_areas(overlapAreaDS, polySetCol) := FUNCTIONMACRO
			LOCAL outrec := {RECORDOF(overlapAreaDS); REAL overlapArea;};
			LOCAL outDS  := PROJECT(overlapAreaDS, TRANSFORM(outrec, SELF.overlapArea := pt.overlap_area(LEFT.polySetCol); SELF := LEFT;));							
			RETURN outDS;
		ENDMACRO;		

		//overlap_polygon: SHOULD DROP OLD VALUES
	 EXPORT overlap_polygon(overlapPolyDS, polySetCol) := FUNCTIONMACRO
			LOCAL outrec := {RECORDOF(overlapPolyDS); STRING overlapPoly;};
			LOCAL outDS  := PROJECT(overlapPolyDS, TRANSFORM(outrec, SELF.overlapPoly := pt.overlap_polygon(LEFT.polySetCol); SELF := LEFT;));							
			RETURN outDS;
		ENDMACRO;			
		
		//poly_union: NOTE DROPS OLD VALUES
	 EXPORT polys_union(unionPolyDs, polySetCol) := FUNCTIONMACRO
			LOCAL outrec := {RECORDOF(unionPolyDs) AND NOT [polySetCol]; STRING polySetCol;};
			LOCAL outDS  := PROJECT(unionPolyDs, TRANSFORM(outrec, SELF.polySetCol := pt.overlap_polygon(LEFT.polySetCol); SELF := LEFT;));							
			RETURN outDS;
		ENDMACRO;			
		
	 //Add BBox:
	 EXPORT polys_corners(bboxDS, polycol) := FUNCTIONMACRO
		  
			LOCAL outrec := RECORD
					RECORDOF(bboxDS);
					REAL latmin;
					REAL latmax;
					REAL lonmin;
					REAL lonmax;
			END;
			
			LOCAL outDS := 
				PROJECT(bboxDS, 
					TRANSFORM(outrec, 
															bbox         := pt.poly_corners(LEFT.polycol);
															SELF.latmin  := bbox[2];
															SELF.latmax  := bbox[4];
															SELF.lonmin  := bbox[1];
															SELF.lonmax  := bbox[3];
															SELF := LEFT;)
				 );
															
			 RETURN outDS;
		ENDMACRO;
			
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
  
  //poly_centroid  //TODO: TEST
  //eg: poly_centroid('POLYGON((40 40, 20 45, 45 30, 40 40))')
  EXPORT STRING poly_centroid(STRING poly_in) := IMPORT(python3, module_location + 'poly_centroid');
    
  //poly_simplify  //TODO: TEST
  //eg: poly_simplify('POLYGON((40 40, 20 45, 45 30, 40 40))')
  EXPORT STRING poly_simplify(STRING poly_in) := IMPORT(python3, module_location + 'poly_simplify');
	
  //poly_corners  //TODO: TEST
  //eg: poly_corners('POLYGON((40 40, 20 45, 45 30, 40 40))')
  EXPORT SET OF REAL poly_corners(STRING poly_in) := IMPORT(python3, module_location + 'poly_corners');
  
  // Support Operations /////////////////////////////////////////////////////
  // These operations can help your wally workflow by assisting in common    //
  // operations                                                              //
  /////////////////////////////////////////////////////////////////////////////      
    
    EXPORT polyRollup(inDS, uidcol, polycol, SortAndDist=TRUE) := FUNCTIONMACRO
      //Takse a ds with a polygon column that is assumed to be a STRING
      //Will rollup based on the UID column and place the polygons in 
      //a set of strings, overwriting the polycol given. 
      
      LOCAL distDS := IF(SortAndDist, SORT(DISTRIBUTE(inDS, HASH(uidcol)), uidcol, LOCAL), inDS);
      LOCAL addSets := 
        PROJECT(distDS, 
                TRANSFORM({RECORDOF(LEFT) AND NOT [polycol]; SET OF STRING polygons;},
                         SELF.polygons := [LEFT.polycol];
                         SELF := LEFT;));
    
      LOCAL stackedPolys := 
        ROLLUP(addSets, 
              LEFT.uidcol = RIGHT.uidcol, 
              TRANSFORM(RECORDOF(addSets),
                        SELF.polygons := LEFT.polygons + RIGHT.polygons;        
                        SELF := RIGHT;));
                        
      RETURN stackedPolys;
    ENDMACRO; 
		
				// EXPORT simplifyInvalid(polyDS, validDS) := MODULE
					
						// LOCAL correctedPoly := JOIN(polyDS, validDS(NOT is_valid), 
											// LEFT.uid = RIGHT.uid, 
											// TRANSFORM(RECORDOF(LEFT), 
																					// SELF.polygon := IF(RIGHT.uid != '', pt.poly_simplify(RIGHT.polygon);
																					// SELF.uid := LEFT.uid;),
										 // LEFT OUTER, SMART);
										 
						// RETURN (correctedPoly);
			// ENDMACRO;    
		
END;





