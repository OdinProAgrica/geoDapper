IMPORT $.polygonTools as pt;
IMPORT $.exampleData as ed;
IMPORT dapper.TransformTools as tt;			

//NEED TO REORDER DEMO DATA. POLYOGNS AT THE END!
//RENAME FUNCS! NOT STANDARD API!


//Define data
NatureReserves   := ed.NatureReserves;
SitesOfInterest  := ed.SitesOfInterest;
TreePreservation := ed.TreePreservation;

//Using Dapper syntax
tt.head(NatureReserves);
tt.head(SitesOfInterest);
tt.head(TreePreservation); // Note it's happy with points too

//Check for invalid polygons
check_NatureReserves := 
	PROJECT(NatureReserves, 
			TRANSFORM({RECORDOF(LEFT); BOOLEAN valid;}, 
											  SELF.valid := pt.wkt_isvalid(LEFT.polygon);
												 SELF := LEFT;));
												 
check_SitesOfInterest := 
	PROJECT(SitesOfInterest, 
			TRANSFORM({RECORDOF(LEFT); BOOLEAN valid;}, 
											  SELF.valid := pt.wkt_isvalid(LEFT.polygon);
												 SELF := LEFT;));
												 
check_TreePreservation := 
	PROJECT(TreePreservation, 
			TRANSFORM({RECORDOF(LEFT); BOOLEAN valid;}, 
											  SELF.valid := pt.wkt_isvalid(LEFT.polygon);
												 SELF := LEFT;));
										
valid_NatureReserves   := check_NatureReserves(valid);
valid_SitesOfInterest  := check_SitesOfInterest(valid);
valid_TreePreservation := check_TreePreservation(valid);

//Look! It works!
tt.nrows(valid_SitesOfInterest);
tt.nrows(SitesOfInterest);

invalid_SOI := check_SitesOfInterest(NOT valid);
tt.head(invalid_SOI);



//areas
area_NatureReserves := 
	PROJECT(valid_NatureReserves, 
								 TRANSFORM({RECORDOF(LEFT); REAL area;},
																			projPoly  := pt.project_polygon(LEFT.polygon, 'EPSG:27700');
																			SELF.area := pt.poly_area(projPoly);
																			SELF := LEFT;));
																			
tt.head(area_NatureReserves);
Total_NR_area := SUM(area_NatureReserves, area);
ave_NR_area := AVE(area_NatureReserves, area);
OUTPUT(Total_NR_area, NAMED('Total_NR_area'));
OUTPUT(ave_NR_area, NAMED('ave_NR_area'));

area_SitesOfInterest := 
	PROJECT(valid_SitesOfInterest, 
								 TRANSFORM({RECORDOF(LEFT); REAL area;},
																			projPoly  := pt.project_polygon(LEFT.polygon, 'EPSG:27700');
																			SELF.area := pt.poly_area(projPoly);
																			SELF := LEFT;));
																			
tt.head(area_SitesOfInterest);
total_SoI_area := SUM(area_SitesOfInterest, area);
ave_SoI_area := AVE(area_SitesOfInterest, area);
OUTPUT(total_SoI_area, NAMED('total_SoI_area'));
OUTPUT(ave_SoI_area, NAMED('ave_SoI_area'));

bbox_SitesOfInterest := pt.bbox(area_SitesOfInterest, polygon);
bbox_NatureReserves  := pt.bbox(area_NatureReserves, polygon);

tt.head(bbox_SitesOfInterest);
tt.head(bbox_NatureReserves);

//Which SoIs intersect NRs?

LOCAL AllMatches := 
	JOIN(bbox_SitesOfInterest, bbox_NatureReserves,
	  //This is where an equality is useful!
		 ((LEFT.latmin >= RIGHT.latmin AND LEFT.latmin <= RIGHT.latmax) OR (LEFT.latmax >= RIGHT.latmin AND LEFT.latmax <= RIGHT.latmax)) AND
		 ((LEFT.lonmin >= RIGHT.lonmin AND LEFT.lonmin <= RIGHT.lonmax) OR (LEFT.lonmax >= RIGHT.lonmin AND LEFT.lonmax <= RIGHT.lonmax)) AND      
		 pt.poly_overlap([LEFT.polygon, RIGHT.polygon]),
		 INNER, SMART);
        



/* 
   //First off, we need to get the data in a good form for our functions. 
   //For dataset wide stuff this is usually uid, polygon so a function
   //exists for this:
   NatureReservesSlim   := pt.CreatePolyDS(NatureReserves, id, polygon);
   SitesOfInterestSlim  := pt.CreatePolyDS(SitesOfInterest, id, wkt);
   TreePreservationSlim := pt.CreatePolyDS(TreePreservation, objectid, wkt);
   
   tt.head(TreePreservationSlim); //just an example
   
   //See if we have any invalid polygons. In practice I'd want to go fix these WHY WE NEED A REPORT COLUMN
   check_NatureReserves 		:= pt.wkts_are_valid(NatureReservesSlim);
   check_SitesOfInterest  := pt.wkts_are_valid(SitesOfInterestSlim);
   check_TreePreservation := pt.wkts_are_valid(TreePreservationSlim);
   
   tt.head(check_SitesOfInterest); 
   SUM(check_SitesOfInterest, (INTEGER) (NOT is_valid));
   
   fix_SitesOfInterest := pt.fixInvalid()
   
   //I'm just going to filter them all (tree preservation doesn't actually have have any invalids
   use_NatureReserves		 := tt.filter(NatureReservesSlim,   check_NatureReserves(is_valid),   uid, uid);
   use_SitesOfInterest  := tt.filter(SitesOfInterestSlim,  check_SitesOfInterest(is_valid),  uid, uid);
   use_TreePreservation := tt.filter(TreePreservationSlim, check_TreePreservation(is_valid), uid, uid); 
   
   
   //Right, good to go. //
   //What area of York is a nature reserve and what is a site of interest
   
   //First project so we can ge the area in meters.  For the UK, that's EPSG:27700. Note default from
   UK_NatureReserves  :=  pt.project_polygons(use_NatureReserves, 'EPSG:27700');
   UK_SitesOfInterest :=  pt.project_polygons(use_SitesOfInterest, 'EPSG:27700');
   
   area_NatureReserves  := pt.polys_area(UK_NatureReserves);
   area_SitesOfInterest := pt.polys_area(UK_SitesOfInterest);
   
   tt.head(area_NatureReserves);
   
   SUM(area_NatureReserves, area);
   SUM(area_SitesOfInterest, area);
   
   AVE(area_NatureReserves, area);
   AVE(area_SitesOfInterest, area);
   
   //Far larger area of Sites of interest
   
   //Add bounding lines to the data so we can use them as a filter condition. Note, having something like postcode or region 
   //That could be used as an equality in the join is preferred. 
   corners_Interest := pt.polys_corners(use_SitesOfInterest);
   corners_Reserves := pt.polys_corners(use_NatureReserves);
   
   join_Interest := bindcol(use_SitesOfInterest, corners_Interest, uid); //TODO: Add to dapper. 
   join_Reserves := bindcol(use_NatureReserves, corners_Reserves, uid); //TODO: Add to dapper. 
   
   
   IntersectingRegions := 
   	JOIN(join_Interest, join_Reserves, 
   					LEFT.lat_min < RIGHT.lat_max AND RIGHT.lat_min < LEFT.lat_max AND
   					LEFT.lon_min < RIGHT.lon_max AND RIGHT.lon_min < LEFT.lon_max AND
   					pt.poly_intersect(LEFT.polygon, RIGHT.polygon),
   					TRANSFORM({STRING uidSoI; STRING uidNR; SET OF STRING polygons;}, 
   															SELF.uidSoI := LEFT.uid; 
   															SELF.uidNR := RIGHT.uid;
   															SELF.polygons := [LEFT.polygon, RIGHT.polygon]), 
   					INNER, ALL);
   					
   tt.head(IntersectingRegions);  //arse, none. Okay, that means that the wokring ones are invalid for some reason. 
   			
   
*/









