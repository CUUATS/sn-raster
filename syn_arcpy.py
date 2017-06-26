# syn_arcpy.py
# The purpose of the script is to synchronize features classes between two databases

import arcpy
from arcpy import env
import os


arcpy.env.workspace = "G:\CUUATS\Sustainable Neighborhoods Toolkit\Data\SustainableNeighborhoodInv.gdb/"
arcpy.env.overwriteOutput = True
PDC = "G:\CUUATS\Sustainable Neighborhoods Toolkit\Data\SustainableNeighborhoodInv.gdb/"
PDC_fc = "StreetCL"

CCGISC = "G:\Resources\Connections\CCGISV.sde/"
CCGISC_fc = "CCGISV.CCGIS.Transportation\CCGISV.CCGIS.StreetCL"

CCGISC_path = CCGISC + CCGISC_fc
PDC_path = PDC + PDC_fc

sr = arcpy.Describe(CCGISC_path).SpatialReference
arcpy.DefineProjection_management(PDC_path, sr)



try:
    base_features = PDC_path
    test_features = CCGISC_path
    sort_field = "FULL_NAME"
    compare_type = "GEOMETRY_ONLY"
    ignore_option = "IGNORE_M;IGNORE_Z"
    xy_tolerance = "1 FEET"
    m_tolerance = 0
    z_tolerance = 0
    attribute_tolerance = "Shape_Length 0.001"
    omit_field = "#"
    continue_compare = "CONTINUE_COMPARE"
    compare_file = "L:\Sustainable Neighborhoods Toolkit\Result.txt"

    compare_result = arcpy.FeatureCompare_management(base_features, test_features, sort_field, compare_type, ignore_option, xy_tolerance, m_tolerance, z_tolerance, attribute_tolerance, omit_field, continue_compare, compare_file)
    print(compare_result.getOutput(1))
    print(arcpy.GetMessage(1))

except Exception as err:
    print(err.args[0])


"""
fields = arcpy.ListFields(CCGISC_path)
CCGISC.dict = {}
for field in fields:
    id = 
"""

"""
with arcpy.da.SearchCursor(PDC_path,"*") as cursor:
    count = 0
    for row in cursor:
        id = row[3]
        print(id)
        count = count + 1
    print("count", count)

"""





