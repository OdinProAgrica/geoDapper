import polygonTools as pt

poly_1 = 'POLYGON((41 45,20 45,21 30,45 30,41 45))'
poly_2 = 'POLYGON ((40 40, 20 45, 45 30, 40 40))'

out = pt._combine_poly(poly_1, poly_2)

print(out)

out = pt.poly_union([poly_1, poly_2])
print(out)
