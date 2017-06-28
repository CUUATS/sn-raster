from setUpDB import WorkspaceFixture
import arcpy
import os


WorkspaceFixture.setUpModule()

class compare_FeatureClass(object):
    GDB_PATH_1 = WorkspaceFixture.PCD_path
    GDB_PATH_2 = WorkspaceFixture.CCGISC_path
    FEATURE_CLASS_1 = WorkspaceFixture.FEATURE_CLASS_NAME
    FEATURE_CLASS_2 = WorkspaceFixture.FEATURE_CLASS_NAME


    @classmethod
    def read_FeatureClass(cls):


            pcd = arcpy.da.SearchCursor(fc_name, ["OID@", "SHAPE@"])
            for row in pcd:
                print("Feature {}".format(row[0]))
                partnum = 0

                for part in row[1]:
                    print("Part {}".format(partnum))

                    for pnt in part:
                        if pnt:
                            print("{}, {}".format(pnt.X, pnt.Y))
                        else:
                            print("Interior Ring")
                    partnum += 1

    @classmethod
    def compare_FeatureClass(cls):


compare_FeatureClass.read_FeatureClass()

WorkspaceFixture.tearDownModule()