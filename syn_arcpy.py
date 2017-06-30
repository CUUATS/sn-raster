# syn_arcpy.py
# The purpose of the script is to synchronize features classes between two databases

import arcpy
from arcpy import env
import os


arcpy.env.workspace = "C:\Users\kml42638\Desktop\TestDB.gdb"
arcpy.env.overwriteOutput = True
PDC_dir = 'C:\Users\kml42638\Desktop\TestDB.gdb'
cl_file = "streetCL_join"
cl1_path = os.path.join(PDC_dir, cl_file)




CCGISC_dir = "C:\Users\kml42638\Desktop\TestDB.gdb"
cl_file1 = "Street_w_Int_Clip"
cl2_path = os.path.join(CCGISC_dir, cl_file1)


#with arcpy.da.SearchCursor(cl1, '*') as cl1:
#    for row in cl1:
#        print(row[1])


#with arcpy.da.SearchCursor(cl2, '*') as cl2:
#    for row in cl2:
#        print(row[1])

try:
    # Set local variables
    base_features = cl1_path
    test_features = cl2_path
    sort_field = "Shape_Length"
    compare_type = "GEOMETRY_ONLY"
    ignore_option = "IGNORE_M;IGNORE_Z"
    xy_tolerance = "0.001 METERS"
    m_tolerance = 0
    z_tolerance = 0
    attribute_tolerance = "Shape_Length 0.001"
    omit_field = "#"
    continue_compare = "CONTINUE_COMPARE"
    compare_file = "L:/Sustainable Neighborhoods Toolkit/result.txt"

    # Process: FeatureCompare
    compare_result = arcpy.FeatureCompare_management(base_features, test_features, sort_field, compare_type,
                                                     ignore_option, xy_tolerance, m_tolerance, z_tolerance,
                                                     attribute_tolerance, omit_field, continue_compare, compare_file)
    print(compare_result.getOutput(1))
    print(arcpy.GetMessages())

except Exception as err:
    print(err.args[0])


result_file = open(compare_file, 'r')
try:
    count = 0
    for line in result_file:
        count = count + 1
    print(count)
finally:
    result_file.close()









