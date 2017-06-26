#syn.py
#The purpose of the script is to synchronize features classes between two databases

import arcpy
from cuuats.datamodel import BaseFeature, NumericField, GeometryField
from cuuats.datamodel import D

class road(BaseFeature):
    SPEED = NumericField(
        'SPEED',
        required = True
    )
    Shape = GeometryField(
        'Shape',
        required = True
    )

road.register(r'G:\CUUATS\Sustainable Neighborhoods Toolkit\Data\SustainableNeighborhoodInv.gdb\StreetCL')

road.objects.(
    SPEED = D('35')
)


#for segment in road.fields:
    #print(segment)
print("Script Finish")