import random
from generate_random_fixed_decimal import generate_random_fixed_decimal
from fixed_point_converter import fixed_point_converter
import math
DATA_WIDTH = 32
INTEGER = 10
FRACTION = 22
MEM_SIZE = 6
TEXT_FILE_NAME_1 = 'TDPM_1'
TEXT_FILE_NAME_2 = 'TDPM_2'
TEXT_FILE_NAME_3 = 'TDPM_3'



##generate random numbers_TDPM1 which will be fetcehd in memory
#numbers_TDPM1 = []
#for number in range(MEM_SIZE):
    #rand_num = generate_random_fixed_decimal (INTEGER, FRACTION)
    #numbers_TDPM1.append(rand_num)
#numbers_TDPM1 = [0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0]
#print (numbers_TDPM1)

numbers_TDPM1 = [10.625,8.875,11,7.0625,0,10.5]

numbers_TDPM1_binary = []
for i in numbers_TDPM1:
    numbers_TDPM1_binary.append(fixed_point_converter(i,DATA_WIDTH,INTEGER,FRACTION))
#print (numbers_TDPM1_binary)
file_name = f"{TEXT_FILE_NAME_1}.txt"
with open(file_name,'w') as f:
    f.write("")
with open(file_name,'a') as f:
    for i in range (MEM_SIZE-1):
        f.write(f'''{numbers_TDPM1_binary[i]}\n''')
    f.write(f'''{numbers_TDPM1_binary[i+1]}''')

numbers_TDPM2 = [10.5,0,0,0,11,10.625]

numbers_TDPM2_binary = []
for i in numbers_TDPM2:
    numbers_TDPM2_binary.append(fixed_point_converter(i,DATA_WIDTH,INTEGER,FRACTION))
#print (numbers_TDPM1_binary)
file_name = f"{TEXT_FILE_NAME_2}.txt"
with open(file_name,'w') as f:
    f.write("")
with open(file_name,'a') as f:
    for i in range (MEM_SIZE-1):
        f.write(f'''{numbers_TDPM2_binary[i]}\n''')
    f.write(f'''{numbers_TDPM2_binary[i+1]}''')

numbers_TDPM3 = [0,0,0,0,10.625,10.625]

numbers_TDPM3_binary = []
for i in numbers_TDPM3:
    numbers_TDPM3_binary.append(fixed_point_converter(i,DATA_WIDTH,INTEGER,FRACTION))
#print (numbers_TDPM1_binary)
file_name = f"{TEXT_FILE_NAME_3}.txt"
with open(file_name,'w') as f:
    f.write("")
with open(file_name,'a') as f:
    for i in range (MEM_SIZE-1):
        f.write(f'''{numbers_TDPM3_binary[i]}\n''')
    f.write(f'''{numbers_TDPM3_binary[i+1]}''')
