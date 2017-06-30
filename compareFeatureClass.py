from setUpDB import WorkspaceFixture
import arcpy
import os

WorkspaceFixture.setUpModule()
WorkspaceFixture.setUpTempDatabase()

class compare_FeatureClass(object):
    GDB_PATH_1 = WorkspaceFixture.PCD_path
    GDB_PATH_2 = WorkspaceFixture.TEMP_path

    FEATURE_CLASS_NAME_1 = WorkspaceFixture.FEATURE_CLASS_NAME
    FEATURE_CLASS_NAME_2 = WorkspaceFixture.FEATURE_CLASS_NAME

    FEATURE_CLASS_PCD = os.path.join(GDB_PATH_1, FEATURE_CLASS_NAME_1)
    FEATURE_CLASS_TEMP = os.path.join(GDB_PATH_2, FEATURE_CLASS_NAME_2)


    @classmethod
    def add_notfication_field(self):
    # add the require field to the target and original database
        arcpy.AddField_management(self.FEATURE_CLASS_PCD, "Match", "TEXT")
        arcpy.AddField_management(self.FEATURE_CLASS_TEMP, "Match", "TEXT")

    @classmethod
    # read the feature class from both database
    def compare_FeatureClass(cls):
        fields = ["SHAPE", "Match"]
        with arcpy.da.UpdateCursor(cls.FEATURE_CLASS_PCD, fields) as cursor1:
            for row1 in cursor1:
                hash1 = hash(row1[0])
                print(hash1)
                with arcpy.da.UpdateCursor(cls.FEATURE_CLASS_TEMP, fields) as cursor2:
                    for row2 in cursor2:
                        hash2 = hash(row2[0])
                        print(hash2)
                        if hash1 == hash2:
                            print("match")
                            row1[1] = "Yes"
                            row2[1] = "Yes"
                            cursor1.updateRow(row1)
                            cursor2.updateRow(row2)


compare_FeatureClass.add_notfication_field()
compare_FeatureClass.compare_FeatureClass()

WorkspaceFixture.tearDownModule()