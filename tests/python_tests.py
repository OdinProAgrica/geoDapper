from polygonTools import *
from unittest import TestCase


class TestWktIsValid(TestCase):
    def setUp(self):
        self.valid = 'POLYGON((40 40, 20 45, 45 30, 40 40))'
        self.invalid = "MADEUP"

    def test_wkt_is_valid_returns_true(self):
        res = wkt_isvalid(self.valid)
        self.assertTrue(res)

    def test_wkt_is_valid_returns_false(self):
        res = wkt_isvalid(self.invalid)
        self.assertFalse(res)


class TestPolyArea(TestCase):
    def setUp(self):
        self.valid = 'POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'
        self.invalid = "MADEUP"

    def test_poly_area_returns_correct_area(self):
        area = poly_area(self.valid)
        self.assertEqual(area, 1)

    def test_poly_area_returns_float_if_valid(self):
        area = poly_area(self.valid)
        self.assertIsInstance(area, float)

    def test_poly_area_returns_zero_if_null(self):
        area = poly_area(self.invalid)
        self.assertEqual(area, 0)

    def test_poly_area_returns_float_if_null(self):
        area = poly_area(self.invalid)
        self.assertIsInstance(area, float)


class TestPolyIsIn(TestCase):
    def setUp(self):
        self.invalid = "MADEUP"
        self.outer = 'POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'
        self.inner = 'POINT(0.5 0.5)'
        self.no_intersect = 'POINT(5 5)'

    def test_poly_isin_returns_true_if_in(self):
        isin = poly_isin(self.inner, self.outer)
        self.assertTrue(isin)

    def test_poly_isin_returns_false_if_bad_p1(self):
        isin = poly_isin(self.invalid, self.outer)
        self.assertFalse(isin)

    def test_poly_isin_returns_false_if_bad_p2(self):
        isin = poly_isin(self.outer, self.invalid)
        self.assertFalse(isin)

    def test_poly_isin_returns_false_if_not_in(self):
        isin = poly_isin(self.no_intersect, self.outer)
        self.assertFalse(isin)


class TestPolyIntersect(TestCase):
    def setUp(self):
        self.invalid = "MADEUP"
        self.outer = 'POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))'
        self.inner = 'POINT(0 0)'
        self.no_intersect = 'POINT(5 5)'

    def test_poly_intersect_returns_true_if_intersect(self):
        isin = poly_intersect(self.inner, self.outer)
        self.assertTrue(isin)

    def test_poly_intersect_returns_false_if_bad_p1(self):
        isin = poly_intersect(self.invalid, self.outer)
        self.assertFalse(isin)

    def test_poly_intersect_returns_false_if_bad_p2(self):
        isin = poly_intersect(self.outer, self.invalid)
        self.assertFalse(isin)

    def test_poly_intersect_returns_false_if_not_in(self):
        isin = poly_intersect(self.no_intersect, self.outer)
        self.assertFalse(isin)


class TestProjectPolygon(TestCase):
    def setUp(self):
        self.invalid = "MADEUP"
        self.valid = 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))'

    def test_project_polygon_fails_invalid_to_proj(self):
        res = project_polygon(self.valid, self.invalid)
        self.assertEqual(res, "")

    def test_project_polygon_fails_invalid_from_proj(self):
        res = project_polygon(self.valid, to_proj="epsg:4326",
                              from_proj=self.invalid)
        self.assertEqual(res, "")

    def test_project_polygon_fails_same_projection(self):
        res = project_polygon(self.valid, to_proj="epsg:4326")
        self.assertEqual(res, self.valid)

    def test_project_polygon_fails_invalid_polygon(self):
        res = project_polygon(self.invalid, "epsg:4326")
        self.assertEqual(res, "")

    def test_project_polygon_projects_correctly(self):
        res = project_polygon(self.valid, "epsg:2169")
        expected = (
            'POLYGON ((-607932.9072591586 -5422473.314434847, '
            '-607828.3014091898 -5311249.8614576, '
            '-495972.9806226798 -5311443.321488622,'
            ' -496060.3111257131 -5422473.02429588, '
            '-607932.9072591586 -5422473.314434847))'
        )
        self.assertEqual(expected, res)


class TestCombinePolygons(TestCase):
    def setUp(self):
        self.invalid = "MADEUP"
        self.valid = 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))'
        self.valid_2 = 'POLYGON ((0 1, 0 2, 1 2, 1 1, 0 1))'

    def test_combine_polygons_fails_bad_p1(self):
        res = combine_polygons(self.invalid, self.valid)
        self.assertEqual("", res)

    def test_combine_polygons_fails_bad_p2(self):
        res = combine_polygons(self.valid, self.invalid)
        self.assertEqual("", res)

    def test_combine_polygons_returns_same_polygon(self):
        res = combine_polygons(self.valid, self.valid)
        self.assertEqual(self.valid, res)

    def test_combine_polygons_fuses_correctly_polygon(self):
        res = combine_polygons(self.valid, self.valid_2)
        expected = "POLYGON ((0 0, 0 1, 0 2, 1 2, 1 1, 1 0, 0 0))"
        self.assertEqual(expected, res)

    def test_combine_polygons_fuses_correctly_multipolygon(self):
        p2 = 'POLYGON ((1 1, 1 2, 2 2, 2 1, 1 1))'
        res = combine_polygons(self.valid, p2)
        expected = ("MULTIPOLYGON (((0 0, 0 1, 1 1, 1 0, 0 0)), "
                    "((1 1, 1 2, 2 2, 2 1, 1 1)))")
        self.assertEqual(expected, res)

    def test_combine_polygons_p1_empty(self):
        res = combine_polygons("POLYGON()", self.valid)
        self.assertEqual(self.valid, res)


class TestPolyUnion(TestCase):
    def setUp(self):
        self.invalid = "MADEUP"
        self.valid = 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))'
        self.valid_2 = 'POLYGON ((0 1, 0 2, 1 2, 1 1, 0 1))'
        self.valid_3 = 'POLYGON ((1 1, 1 2, 2 2, 2 1, 1 1))'

    def test_poly_union_single_p(self):
        res = poly_union([self.valid])
        self.assertEqual(self.valid, res)

    def test_poly_union_duplicate_p(self):
        res = poly_union([self.valid] * 2)
        self.assertEqual(self.valid, res)

    def test_poly_union_no_p(self):
        res = poly_union([])
        self.assertEqual("GEOMETRYCOLLECTION EMPTY", res)

    def test_poly_union_2_polys(self):
        res = poly_union([self.valid, self.valid_2])
        expected = "POLYGON ((0 0, 0 1, 0 2, 1 2, 1 1, 1 0, 0 0))"
        self.assertEqual(expected, res)

    def test_poly_union_2_poly_multipoly(self):
        res = poly_union([self.valid, self.valid_3])
        expected = ("MULTIPOLYGON (((0 0, 0 1, 1 1, 1 0, 0 0)), "
                    "((1 1, 1 2, 2 2, 2 1, 1 1)))")
        self.assertEqual(expected, res)

    def test_poly_union_3_polys(self):
        res = poly_union([self.valid, self.valid_2, self.valid_3])
        expected = "POLYGON ((0 0, 0 1, 0 2, 1 2, 2 2, 2 1, 1 1, 1 0, 0 0))"
        self.assertEqual(expected, res)

    def test_poly_union_bad_poly(self):
        res = poly_union([self.valid, self.valid_3, self.invalid])
        expected = ("MULTIPOLYGON (((0 0, 0 1, 1 1, 1 0, 0 0)), "
                    "((1 1, 1 2, 2 2, 2 1, 1 1)))")
        self.assertEqual(expected, res)
