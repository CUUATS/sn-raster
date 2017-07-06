import arcpy
import os
import shutil
import tempfile


def setUpModule():
    WorkspaceFixture.setUpModule()

def tearDownModule():
    WorkspaceFixture.tearDownModule()

class WorkspaceFixture(object):
    PCD_NAME = 'pdc.gdb'
    CCGISC_NAME = 'ccgisc.gdb'
    TEMP_NAME = 'temp.gdb'
    FEATURE_CLASS_NAME = 'Road'
    FEATURE_CLASS_TYPE = 'POLYLINE'
    FEATURE_CLASS_FIELDS = (
        ('road_name', 'TEXT', 50),
        ('road_id', 'TEXT', 20),
        ('speed', 'LONG', 5),
        ('lpd', 'LONG', 2)
    )
    PDC_FEATURE_CLASS_DATA = (
        ('Road A', '2', 35, 2, ([0, 0], [0, 6])),
        ('B Avenue', '3', 40, 4, ([0, 0], [5, 1])),
        ('C Street', '4', 25, 1, ([0, 0], [0, -5]))
    )
    CCGISC_FEATURE_CLASS_DATA = (
        ('Road A', '2', 35, 2, ([0, 0], [0, 6])),
        ('B Avenue', '3', 40, 4, ([0, 0], [5, 1])),
        ('C Street', '4', 25, 1, ([0, 0], [0, -5])),
        ('D Road', '5', 25, 2, ([1, 4], [2, 5]))
    )

    @classmethod
    def setUpModule(cls):
        # Create the path for geodatabase
        cls.workspace_dir = tempfile.mkdtemp()
        cls.PCD_path = os.path.join(cls.workspace_dir, cls.PCD_NAME)
        cls.CCGISC_path = os.path.join(cls.workspace_dir, cls.CCGISC_NAME)
        cls.TEMP_path = os.path.join(cls.workspace_dir, cls.TEMP_NAME)

        # Create file geodatabase
        arcpy.CreateFileGDB_management(cls.workspace_dir, cls.PCD_NAME)
        arcpy.CreateFileGDB_management(cls.workspace_dir, cls.CCGISC_NAME)

        # Create a feature classes.
        pcd_fc_path = os.path.join(cls.PCD_path, cls.FEATURE_CLASS_NAME)
        ccgisc_fc_path = os.path.join(cls.CCGISC_path, cls.FEATURE_CLASS_NAME)

        arcpy.CreateFeatureclass_management(
            cls.PCD_path, cls.FEATURE_CLASS_NAME, cls.FEATURE_CLASS_TYPE
        )
        arcpy.CreateFeatureclass_management(
            cls.CCGISC_path, cls.FEATURE_CLASS_NAME, cls.FEATURE_CLASS_TYPE
        )

        # Define coordinate system
        #descr = arcpy.Describe("G:\Resources\Connections\CCGISV.sde\CCGISV.CCGIS.Transportation\CCGISV.CCGIS.StreetCL")
        #sr = descr.spatialReference
        #descr1 = arcpy.Describe("G:\CUUATS\Sustainable Neighborhoods Toolkit\Data\SustainableNeighborhoodsToolkit.gdb\GISC_join")
        #sr1 = descr1.spatialReference
        #arcpy.DefineProjection_management(pcd_fc_path, sr1)
        #arcpy.DefineProjection_management(ccgisc_fc_path, sr)


        # Add fields to the feature class
        for (field_name, field_type, field_precision) in cls.FEATURE_CLASS_FIELDS:
           arcpy.AddField_management(
                pcd_fc_path, field_name, field_type, field_precision)
           arcpy.AddField_management(
                ccgisc_fc_path, field_name, field_type, field_precision)


        # Add data to the feature class
        fields_name = [f[0] for f in cls.FEATURE_CLASS_FIELDS] + ['SHAPE@']
        with arcpy.da.InsertCursor(pcd_fc_path, fields_name) as cursor:
            for row in cls.PDC_FEATURE_CLASS_DATA:
                cursor.insertRow(row)
        with arcpy.da.InsertCursor(ccgisc_fc_path, fields_name) as cursor:
            for row in cls.CCGISC_FEATURE_CLASS_DATA:
                cursor.insertRow(row)

    @classmethod
    def setUpTempDatabase(cls):
        arcpy.CreateFileGDB_management(cls.workspace_dir, cls.TEMP_NAME)
        cls.TEMP_FC_PATH = os.path.join(cls.workspace_dir, cls.TEMP_NAME, cls.FEATURE_CLASS_NAME)
        cls.CCGIS_FC_PATH = os.path.join(cls.CCGISC_path, cls.FEATURE_CLASS_NAME)
        arcpy.Copy_management(cls.CCGIS_FC_PATH, cls.TEMP_FC_PATH)

    @classmethod
    def tearDownModule(cls):
        shutil.rmtree(cls.workspace_dir)




