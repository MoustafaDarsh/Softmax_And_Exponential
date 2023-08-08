import math
from fixed_point_converter import fixed_point_converter
TEXT_FILE_NAME = 'LUT_2'
DATA_WIDTH = 32
INTEGER = 10
FRACTION = 22
numbers = [0.0 , 0.125 , 0.25 , 0.375 , 0.5 , 0.625 , 0.75 , 0.875]
exp_values = []
for i in numbers:
    exp_values.append(math.exp(-i))
exp_values_binary = []
for i in exp_values:
    exp_values_binary.append(fixed_point_converter(i,DATA_WIDTH,INTEGER,FRACTION))
file_name = f"{TEXT_FILE_NAME}.txt"
with open(file_name,'w') as f:
    f.write("")
with open(file_name,'a') as f:
    for i in range (len(exp_values_binary)-1):
        f.write(f'''{exp_values_binary[i]}\n''')
    f.write(f'''{exp_values_binary[i+1]}''')

    