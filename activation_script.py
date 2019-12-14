import numpy as np
from random import uniform
from numpy import genfromtxt
import math

class Converter(object):
   
    def __init__(self,bit=(3,5)):
        self.total_bit = bit[0] + bit[1]
        self.upper_limit = (2**(bit[0] - 1)) - 1
        self.lower_limit = -(2**(bit[0] - 1))
        self.shift_amount = bit[1] - 1
        self.UPPER_BOUND = (1 << (self.total_bit - 1))-1
        self.LOWER_BOUND = -(1 << (self.total_bit - 1))
        self.mul_amount_for_shift = 2**self.shift_amount
        if self.total_bit >= 32:
            self.value_type = np.int64
        else:
            self.value_type = np.int32
        self.longest_type = np.int64
        print('Using Q{0}.{1}-bit precision...'.format(bit[0],bit[1]))
    def f2i(self, n):
        if isinstance( n, np.ndarray ):
            n = np.clip( n, self.lower_limit, self.upper_limit )
        else:
            if n > self.upper_limit:
                print('n: {0}, max: {1}'.format(n,self.upper_limit))
                n = self.upper_limit
            elif n < self.lower_limit:
                print('n: {0}, max: {1}'.format(n,self.lower_limit))
                n = self.lower_limit
            #raise Exception("integer bit width {0} is not enough".format(self.total_bit))
        return self.value_type(np.sign(n) * np.abs(n) * self.mul_amount_for_shift)
    def i2f(self, n):
        try:
            return np.float32(n)/self.mul_amount_for_shift
        except:
            for x in n:
                x = np.float32(x)/self.mul_amount_for_shift
            return n
    def add(self, a, b):
        return a+b
    def sub(self, a, b):
        return a-b
    def mul(self, a, b):
        #print("a:{0}, b:{1}, a*b:{2}\n",a,b,a*b)
        #return (a * b)/self.mul_amount_for_shift
        return self.value_type((np.int64(a) * np.int64(b)) >> self.shift_amount)
    def div(self, a, b):
        #return (a * self.mul_amount_for_shift)/b
        return (a << self.shift_amount)/b
    def convert_list_f2i(self, x):
        return_ = [self.f2i(i) for i in x]
        return return_
    def convert_list_i2f(self, x):
        return_ = [self.i2f(i) for i in x]
        return return_
   
def fixed_to_binary(fixed_point_number):
    try:
        if fixed_point_number >= 0:
            binary = '0'*(8-len(bin(fixed_point_number)[2:])) + bin(fixed_point_number)[2:]
        else:
            binary = bin((1 << 8) + fixed_point_number)[2:]
        return binary
    except TypeError:
        binary = ['0'*(8-len(bin(x)[2:])) + bin(x)[2:] if x >= 0 else bin((1 << 8) + x)[2:] for x in fixed_point_number]
        return binary
    
def activation_grouping_pw(filename, out_file, array_dimx, array_dimy, num_channels):
    activations = genfromtxt(filename, delimiter=',')
    c = Converter()
    activations = activations.reshape((-1,num_channels))
    activations = c.f2i(activations)
    activations = np.vectorize(fixed_to_binary)(activations)
    num_sets = int(num_channels / array_dimx)
    sets = []
    for i in range(num_sets):
        sets.append(activations[:,i*array_dimx:(i+1)*array_dimx])
        
    groups = []
    num_groups = int(activations.shape[0] / array_dimy)
    print(num_groups)
    for j in range(num_groups):
        if j % 2 is 0:
            for i in range(num_sets):
                groups.append(sets[i][j*array_dimy:(j+1)*array_dimy,])
        else:
            for i in reversed(range(num_sets)):
                groups.append(sets[i][j*array_dimy:(j+1)*array_dimy,])
            
    #print(groups[0].shape)
    indices = np.arange(array_dimx)   
  
    #num_iter = int(out_channels / array_dimx)  
    with open(out_file, 'w') as f:                 
        for i in range(num_groups*num_sets):
            if i%2==0 and i!=0:
                for stall1 in range(array_dimx):
                    current = ''
                    for stall in range(array_dimx):                        
                        current += '00000000'
                    f.write(f'{current}\n')
                
            for k in range(array_dimx):
                current = ''
                for j in range(array_dimx):
                    current += groups[i][indices[j]][j]
                indices = np.roll(indices, 1)
                f.write(f'{current}\n')
                
        for stall1 in range(array_dimx):
            current = ''
            for stall in range(array_dimx):                        
                current += '00000000'
            f.write(f'{current}\n')
             
        
def activation_grouping_dw(filename, out_file, num_pe, num_channels, dim, filter_size=3):
    activations = genfromtxt(filename, delimiter=',')
    c = Converter()
    activations = activations.reshape((-1,num_channels))
    activations = c.f2i(activations)
    activations = np.vectorize(fixed_to_binary)(activations)
    
    final_groups = []
    for i in range(num_channels):
        act_seq = []
        temp = activations[:,i]
        act_dim = int(math.sqrt(temp.size))
        for ver in range(act_dim-2):
            for hor in range(act_dim-2):
                for f1 in range(filter_size):
                    for f2 in range(filter_size):
                        index = ver*act_dim + hor + f1*dim + f2
                        act_seq.append(temp[index])
                        
        final_groups.append(act_seq)
        
    num_sets = int(num_channels / num_pe)
    num_loops = int((act_dim-2)*(act_dim-2)/ num_pe)
    
    with open(out_file, 'w') as f:
        for j in range(num_loops):
            for k in range(num_sets): 
                for l in range(num_pe*filter_size*filter_size):
                    current = ''
                    for m in range(num_pe):
                        current += final_groups[k*num_pe + m][j*num_pe + l]
                    f.write(f'{current}\n')
                                       
                    
def activation_grouping_dw_systolic(filename, out_file, index, num_channels, act_dim):
    activations = genfromtxt(filename, delimiter=',')
    c = Converter()
    activations = activations.reshape((-1,num_channels))
    activations = c.f2i(activations)
    activations = np.vectorize(fixed_to_binary)(activations)
    
    activations_1 = activations[:,index].reshape((-1, act_dim))
    remainder = int((act_dim - 5) % 3)
    loop_range = int((act_dim - remainder - 5) / 3)
    
    with open(out_file,'w') as f:
        for i in range(loop_range):           
            for j in range(3):
                current = ''
                for k in range(3):
                    current += activations_1[j,k+3*i]
                if i is 0:
                    current += '00000000'
                    current += '00000000'
                    f.write(f'{current}\n')
                else:
                    current += activations_1[(act_dim-3+j),3+3*(i-1)]
                    current += activations_1[(act_dim-6+j),4+3*(i-1)]
                    f.write(f'{current}\n')
                
            for j in range(3,6):
                current = ''
                for k in range(3):
                    current += activations_1[j,k+3*i]
                current += activations_1[j-3,3+3*i]
                if i is 0:
                    current += '00000000'
                    f.write(f'{current}\n')
                else:
                    current += activations_1[(act_dim-6+j),4+3*(i-1)]
                    
            for j in range(6, act_dim):
                current = ''
                for k in range(3):
                    current += activations_1[j,k+3*i]
                current += activations_1[j-3,3+3*i]
                current += activations_1[j-6,4+3*i]
                f.write(f'{current}\n')
                
            if (i == loop_range-1):
                for j in range(act_dim, act_dim+3):
                    current = ''
                    for k in range(3):
                        current += '00000000'
                    current += activations_1[j-3,3+3*i]
                    current += activations_1[j-6,4+3*i]
                    f.write(f'{current}\n')
                    
                for j in range(act_dim+3, act_dim+6):
                    current = ''
                    for k in range(4):
                        current += '00000000'
                    current += activations_1[j-6,4+3*i]
                    f.write(f'{current}\n')
                    
def activation_grouping_standard(filename, out_file, num_channels, act_dim=114, filter_size=3, array_dimx=16, array_dimy=16):
    activations = genfromtxt(filename, delimiter=',')
    c = Converter()
    activations = activations.reshape((-1,num_channels))
    activations = c.f2i(activations)
    activations = np.vectorize(fixed_to_binary)(activations)
    activations = activations.reshape((act_dim, act_dim, num_channels))
    
    for i in range(filter_size):
        for j in range(filter_size):
            curr_activation = activations[i:i+112,j:j+112,:,].reshape((-1,num_channels))
            sub_grouping(out_file, curr_activation, num_channels)

def sub_grouping(out_file, activations, num_channels, array_dimx = 16, array_dimy = 16):
    
    num_sets = int(num_channels / array_dimx)
    sets = []
    for i in range(num_sets):
        sets.append(activations[:,i*array_dimx:(i+1)*array_dimx])
        
    groups = []
    num_groups = int(activations.shape[0] / array_dimy)
    
    for j in range(num_groups):
        if j % 2 is 0:
            for i in range(num_sets):
                groups.append(sets[i][j*array_dimy:(j+1)*array_dimy,])
        else:
            for i in reversed(range(num_sets)):
                groups.append(sets[i][j*array_dimy:(j+1)*array_dimy,])
            
    indices = np.arange(array_dimx)   

    with open(out_file, 'a') as f:                 
        for i in range(num_groups*num_sets):
            if i%2==0 and i!=0:
                for stall1 in range(array_dimx):
                    current = ''
                    for stall in range(array_dimx):                        
                        current += '00000000'
                    f.write(f'{current}\n')
                
            for k in range(array_dimx):
                current = ''
                for j in range(array_dimx):
                    current += groups[i][indices[j]][j]
                indices = np.roll(indices, 1)
                f.write(f'{current}\n')
                
        for stall1 in range(array_dimx):
            current = ''
            for stall in range(array_dimx):                        
                current += '00000000'
            f.write(f'{current}\n')                