IMPORT polygontools as pt;


geoSet := DATASET([{'a', ['POLYGON((41 45,20 45,21 30,45 30,41 45))', 'POLYGON ((40 40, 20 45, 45 30, 40 40))']}], 
                    {STRING uid; SET OF STRING polygons;});
                                    
                                  
pt.polys_union(geoSet);
// pt.overlap_areas(mergedData);
// pt.overlap_polygons(mergedData);
    