from setUpDB import WorkspaceFixture
import arcpy
import os
from datetime import date
from hashlib import md5
WorkspaceFixture.setUpModule()
WorkspaceFixture.setUpTempDatabase()

class compare_FeatureClass(object):
    GDB_PATH_1 = WorkspaceFixture.PCD_path
    GDB_PATH_2 = WorkspaceFixture.TEMP_path

    FEATURE_CLASS_NAME_1 = WorkspaceFixture.FEATURE_CLASS_NAME
    FEATURE_CLASS_NAME_2 = WorkspaceFixture.FEATURE_CLASS_NAME

    FEATURE_CLASS_PCD = os.path.join(GDB_PATH_1, FEATURE_CLASS_NAME_1)
    FEATURE_CLASS_TEMP = os.path.join(GDB_PATH_2, FEATURE_CLASS_NAME_2)

    print(GDB_PATH_2)


    @classmethod
    def addNotificationField(cls):
    # Add the require field to the target and original database
        pcd_list = ["Match", "Del", "Added"]
        for field in pcd_list:
            arcpy.AddField_management(cls.FEATURE_CLASS_PCD, field, "TEXT")
        temp_list = ["Match", "Added"]
        for field in temp_list:
            arcpy.AddField_management(cls.FEATURE_CLASS_TEMP, field, "TEXT")


    @classmethod
    # Read the feature class from both database and compare the shape, update if matches are found
    def compareFeatureClassShape(cls):
        fields = ["SHAPE@", "Match"]
        match = 0
        with arcpy.da.UpdateCursor(cls.FEATURE_CLASS_PCD, fields) as cursor1:
            for row1 in cursor1:
                with arcpy.da.UpdateCursor(cls.FEATURE_CLASS_TEMP, fields) as cursor2:
                    for row2 in cursor2:
                        if row1[0].equals(row2[0]):
                            match = match + 1
                            row1[1] = "Yes"
                            row2[1] = "Yes"
                            cursor1.updateRow(row1)
                            cursor2.updateRow(row2)

        print("There are {} matches".format(match))


    @classmethod
    # Mark PCD fc class for deletion
    def deletePCDFeatureClass(cls):
        fields = ["Match", "Del"]
        with arcpy.da.UpdateCursor(cls.FEATURE_CLASS_PCD, fields) as cursor:
            for row in cursor:
                if row[0] != "Yes":
                    row[1] = "Yes"
                    cursor.updateRow(row)


    @classmethod
    # Mark new features with current date
    def addTempFeatureClass(cls):
        field = ["Match", "Added"]
        with arcpy.da.UpdateCursor(cls.FEATURE_CLASS_TEMP, field) as cursor_temp:
            for row in cursor_temp:
                if row[0] != "Yes":
                    row[1] = date.today().strftime('%Y%m%d')
                    cursor_temp.updateRow(row)


    @classmethod
    # Append new features into the PCD database
    def appendFeature(cls):
        arcpy.MakeFeatureLayer_management(cls.FEATURE_CLASS_TEMP, 'temp_layer')
        arcpy.SelectLayerByAttribute_management('temp_layer', "NEW_SELECTION", "Added IS NOT NULL")
        arcpy.Append_management('temp_layer', cls.FEATURE_CLASS_PCD, "NO_TEST")
        arcpy.SelectLayerByAttribute_management('temp_layer', "CLEAR_SELECTION")
        arcpy.Delete_management('temp_layer')

def main():
    compare_FeatureClass.addNotificationField()
    compare_FeatureClass.compareFeatureClassShape()
    compare_FeatureClass.deletePCDFeatureClass()
    compare_FeatureClass.addTempFeatureClass()
    compare_FeatureClass.appendFeature()
    WorkspaceFixture.tearDownModule()


if __name__ == "__main__":
    main()