import arcpy
import os
from datetime import date
import tempfile
import shutil

class databaseFixture(object):
    CCGIS_DB = "G:\Resources\Connections\CCGISV.sde"
    CCGIS_NAME = "CCGISV.CCGIS.Transportation\CCGISV.CCGIS.StreetCL"
    CCGIS_FC = os.path.join(CCGIS_DB, CCGIS_NAME)
    CCGIS_TEMP_DB = "CCGIS_TEMP.gdb"

    PCD_DB = "G:\CUUATS\Sustainable Neighborhoods Toolkit\Data\SustainableNeighborhoodsToolkit.gdb"
    PCD_NAME = "GISC_join"
    PCD_FC = os.path.join(PCD_DB, PCD_NAME)
    PCD_TEMP_DB = "PCD_TEMP.gdb"

    temp_dir = tempfile.mkdtemp()
    print(temp_dir)

    @classmethod
    def setupTempCCGISDatabase(cls):
        arcpy.CreateFileGDB_management(cls.temp_dir, cls.CCGIS_TEMP_DB)
        print("in_feature", cls.CCGIS_FC)
        print("out_feature_class", os.path.join(cls.temp_dir, cls.CCGIS_TEMP_DB, "CCGIS_StreetCL"))
        arcpy.CopyFeatures_management(cls.CCGIS_FC, os.path.join(cls.temp_dir, cls.CCGIS_TEMP_DB, "CCGIS_StreetCL"))
        print("Setup Success")


    @classmethod
    def setupTempPCDDatabase(cls):
        arcpy.CreateFileGDB_management(cls.temp_dir, cls.PCD_TEMP_DB)
        arcpy.CopyFeatures_management(cls.PCD_FC, os.path.join(cls.temp_dir, cls.PCD_TEMP_DB, "PCD_StreetCL"))


    @classmethod
    def deleteTempDatabase(cls):
        shutil.rmtree(cls.temp_dir)
        print("Deleted Dir")



class compareFeatureClass(object):
    GDB_PATH_1 = os.path.join(databaseFixture.temp_dir, databaseFixture.PCD_TEMP_DB)
    GDB_PATH_2 = os.path.join(databaseFixture.temp_dir, databaseFixture.CCGIS_TEMP_DB)

    FEATURE_CLASS_NAME_1 = "PCD_StreetCL"
    FEATURE_CLASS_NAME_2 = "CCGIS_StreetCL"

    FEATURE_CLASS_PCD = os.path.join(GDB_PATH_1, FEATURE_CLASS_NAME_1)
    FEATURE_CLASS_TEMP = os.path.join(GDB_PATH_2, FEATURE_CLASS_NAME_2)


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
        fields = ["SHAPE", "Match"]
        match = 0
        with arcpy.da.UpdateCursor(cls.FEATURE_CLASS_PCD, fields) as cursor1:
            for row1 in cursor1:
                hash1 = hash(row1[0])
                with arcpy.da.UpdateCursor(cls.FEATURE_CLASS_TEMP, fields) as cursor2:
                    for row2 in cursor2:
                        hash2 = hash(row2[0])
                        if hash1 == hash2:
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
    databaseFixture.setupTempCCGISDatabase()
    databaseFixture.setupTempPCDDatabase()
    compareFeatureClass.addNotificationField()
    compareFeatureClass.compareFeatureClassShape()
    compareFeatureClass.deletePCDFeatureClass()
    compareFeatureClass.addTempFeatureClass()
    compareFeatureClass.appendFeature()
    #databaseFixture.deleteTempDatabase()

if __name__ == "__main__":
    main()