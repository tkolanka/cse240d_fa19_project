import numpy as np
from random import uniform
from numpy import genfromtxt
from activation_script import Converter, fixed_to_binary

def weight_grouping_pw(filename, filed, filea, out_channels, array_dimx, array_dimy):
    weights = genfromtxt(filename, delimiter=',')
    c = Converter()
    weights = weights.reshape((-1,out_channels))
    weights = c.f2i(weights)
    weights = np.vectorize(fixed_to_binary)(weights)
    
    num_sets = int(out_channels / array_dimx)
    sets = []
    for i in range(num_sets):
        sets.append(weights[:,i*array_dimx:(i+1)*array_dimx])
        
    groups = []
    num_groups = int(weights.shape[0] / array_dimy)
    for i in range(num_sets):
        for j in range(num_groups):
            groups.append(sets[i][j*array_dimy:(j+1)*array_dimy,])
    
    with open(filed, 'w') as fd, open(filea, 'w') as fa:
        for i in range(num_groups*num_sets):
            current_data = ''
            current_addr = ''
            addr = '0'*(8-len(bin(i)[2:])) + bin(i)[2:]
            for j in range(array_dimy):
                for k in range(array_dimx):
                    current_data += groups[i][k][j]
                    current_addr += addr
            fd.write(f'{current_data}\n')
            fa.write(f'{current_addr}\n')

def weight_grouping_dw(filename, out_file, num_channels, num_pe, act_dim, filter_size):
    weights = genfromtxt(filename, delimiter=',')
    c = Converter()
    weights = weights.reshape((-1,num_channels))
    weights = c.f2i(weights)
    weights = np.vectorize(fixed_to_binary)(weights)
    
    num_sets = int(num_channels / num_pe)
    num_loops = int(act_dim ** 2 / num_pe)
    
    with open(out_file, 'w') as f:
        for i in range(num_loops):
            for j in range(num_sets):
                for k in range(num_pe):
                    for l in range(filter_size**2):
                        current = ''
                        for m in range(num_pe):
                            current += weights[l,j*num_pe + m]
                        f.write(f'{current}\n')
   
def weight_grouping_dw_systolic(filename, out_file, index, num_channels, filter_size=3):  
    weights = genfromtxt(filename, delimiter=',')
    c = Converter()
    weights = weights.reshape((-1,num_channels))
    weights = c.f2i(weights)
    weights = np.vectorize(fixed_to_binary)(weights)

    weights_1 = weights[:,index].reshape((-1, filter_size)) 

    with open(out_file, 'w') as f:  
        current=''
        for i in range(filter_size):
            for j in reversed(range(filter_size)):
                current += weights_1[i][j]
        f.write(f'{current}\n')

def weight_grouping_standard(filename, out_filed, out_filea, in_channels, out_channels, filter_size=3):
    weights = genfromtxt(filename, delimiter=',')
    c = Converter()
    weights = weights.reshape((-1,out_channels))
    weights = c.f2i(weights)
    weights = np.vectorize(fixed_to_binary)(weights)
    weights = weights.reshape((filter_size*filter_size, in_channels, out_channels))
    
    for j in range(filter_size*filter_size):
        curr_weights = weights[j,:,:,].reshape((-1, out_channels))
        sub_grouping(out_filed, out_filea, curr_weights, out_channels, j)
    
def sub_grouping(out_filed, out_filea, weights, out_channels, index, array_dimx=16, array_dimy=16):
    num_sets = int(out_channels / array_dimx)
    sets = []
    for i in range(num_sets):
        sets.append(weights[:,i*array_dimx:(i+1)*array_dimx])
        
    groups = []
    num_groups = int(weights.shape[0] / array_dimy)
    for i in range(num_sets):
        for j in range(num_groups):
            groups.append(sets[i][j*array_dimy:(j+1)*array_dimy,])
    
    with open(out_filed, 'a') as fd, open(out_filea, 'a') as fa:
        for i in range(num_groups*num_sets):
            current_data = ''
            current_addr = ''
            addr = '0'*(8-len(bin(i+(8*index))[2:])) + bin(i+(8*index))[2:]
            for j in range(array_dimy):
                for k in range(array_dimx):
                    current_data += groups[i][k][j]
                    current_addr += addr
            fd.write(f'{current_data}\n')
            fa.write(f'{current_addr}\n')            