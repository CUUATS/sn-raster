#checkValue.py
#This script check the value for the input field and return whether any of the field contain values

import arcpy
from arcpy import env

arcpy.env.workspace = "G:\CUUATS\Sustainable Neighborhoods Toolkit\Data\IntersectionEditing.gdb"
in_feature = "IntersectionJoin"
calField = "hasValue"
findstr = "PCD"

list = []

#set up list
fields = arcpy.ListFields(in_feature)
for field in fields:
    i = field.name.find(findstr)
    if i == 0:
        list.append(field.name)

print(list)
del list[0:2]
list.remove("PCD_PCDQC_StreetIntersection_Database_Year_TMC")
print(list)


for otherField in list:
    print(otherField)
    codeblock = """def findValue(a, ori):
    if a != 0:
        return ("Yes")
    else:
        return (ori)"""

    expression = "findValue(!{}!, !hasValue!)".format(otherField)

    if calField == "Yes":
        continue
    arcpy.CalculateField_management(in_feature, calField, expression=expression, expression_type="PYTHON_9.3", code_block=codeblock)






