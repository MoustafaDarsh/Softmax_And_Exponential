import math
from fixed_point_converter import fixed_point_converter
TEXT_FILE_NAME = 'LUT_1'
DATA_WIDTH = 32
INTEGER = 10
FRACTION = 22
numbers = [0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0]
exp_values = []
for i in numbers:
    exp_values.append(math.exp(-i))
exp_values_binary = []
for i in exp_values:
    exp_values_binary.append(fixed_point_converter(i,DATA_WIDTH,INTEGER,FRACTION))
#print (exp_values_binary)
file_name = f"{TEXT_FILE_NAME}.txt"
with open(file_name,'w') as f:
    f.write("")
with open(file_name,'a') as f:
    for i in range (len(exp_values_binary)-1):
        f.write(f'''{exp_values_binary[i]}\n''')
    f.write(f'''{exp_values_binary[i+1]}''')