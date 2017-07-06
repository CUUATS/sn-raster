from setUpDB import WorkspaceFixture
import arcpy
import os
import tempfile
import shutil

inFeatureClass = "G:\Resources\Connections\CCGISV.sde\CCGISV.CCGIS.Transportation\CCGISV.CCGIS.StreetCL"
workspace_dir = tempfile.mkdtemp()
outName = os.path.join(workspace_dir, "TEMP_DB.gdb", "StreetCL")
print(outName)

arcpy.CreateFileGDB_management(workspace_dir, "TEMP_DB")
arcpy.CopyFeatures_management(inFeatureClass, outName)

print(workspace_dir)
shutil.rmtree(workspace_dir)
