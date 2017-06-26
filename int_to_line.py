#int_to_line.py
#This script takes intersection and road segment and determine the direction of the road segment in contrast to the intersection.

import arcpy
from arcpy import env
from arcpy.sa import *
arcpy.CheckOutExtension("Spatial")
arcpy.env.overwriteOutput = True

#input configuration
env.workspace = "C:/Users/kml42638/Desktop/testDB.gdb"
print("The name of the workspace is " + env.workspace)
streetCL = "GGISC_streetCL"
intersections = "Intersections_all"


def main(intersections, streetCL):
    int_buffer = buffer_function(intersections)
    int_point = intersect_function(int_buffer, streetCL)
    near_int = near_function(int_point, intersections)
    add_direction(int_point)
    join_dir_function(int_point, streetCL)


def buffer_function(int):
    print("Finish buffer")
    return(arcpy.Buffer_analysis(intersections, "in_memory" + "\\" + "int_buff", 30))


def intersect_function(int_buffer, streetCL):
    print("Finish intersect")
    return(arcpy.Intersect_analysis(
                in_features=[int_buffer, streetCL],
                out_feature_class="int_point",
                output_type="point"
            )
        )


def near_function(int_point, intersections):
    print("Finish near feature")
    return(arcpy.Near_analysis(
                in_features=int_point,
                near_features=intersections,
                location=False,
                angle=True,
                search_radius=31
            )
        )


def add_direction(int_point):
    arcpy.AddField_management(
        in_table=int_point,
        field_name="dir",
        field_type="TEXT",
        field_length=3
    )
    arcpy.CalculateField_management(
        in_table=int_point,
        field="dir",
        expression_type="PYTHON_9.3",
        expression="reclass(!NEAR_ANGLE!)",
        code_block= """def reclass(angle):
                            if (angle >= -45 and angle <=45):
                                return ("W")
                            elif (angle >= -135 and angle <=-45):
                                return ("N")
                            elif (angle >=-45 and angle <=135):
                                return ("S")
                            else:
                                return ("E")"""
    )


def join_dir_function(int_point, streetCL):
    arcpy.SpatialJoin_analysis(
        target_features=streetCL,
        join_features=int_point,
        out_feature_class="streetCL_join",
        match_option="WITHIN_A_DISTANCE",
        search_radius=1
    )




main(intersections, streetCL)







