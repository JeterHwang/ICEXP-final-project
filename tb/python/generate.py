import numpy as np
import os
from os import path

vector_path = '../dat/vector_in.dat'
matrix_path = '../dat/matrix_in.dat'
columnIndex_path = '../dat/columnIndex_in.dat'
ipv_path = '../dat/ipv_in.dat'
vov_path = '../dat/vov_out.dat'
golden_path = '../dat/data_out.dat'

data_range = np.arange(-128, 128, 1)
probability_matrix = np.array([0.5/255 for i in range(256)])
probability_matrix[128] = 0.5
probability_vector = np.array([1.0/256 for i in range(256)])

array_row = 128
array_col = 128

def generate_matrix():
    return np.random.choice(data_range, (array_row, array_col), p=probability_matrix)

def generate_vector():
    return np.random.choice(data_range, array_col, p=probability_vector)

def solve(matrix, vector):
    mat = []
    row = []
    col = []
    ipv = []
    vov = []
    print(matrix)
    for i in range(array_row):
        mat_tp = []
        row_tp = []
        col_tp = []
        for j in range(array_col):
            if matrix[i][j] != 0:
                mat_tp.append(matrix[i][j])
                row_tp.append(i)
                col_tp.append(j)
        if len(mat_tp) == 0: # in case the whole row is zero 
            mat_tp.append(0)
            row_tp.append(i)
            col_tp.append(0)
        for M, R, C in zip(mat_tp, row_tp, col_tp):
            mat.append(np.binary_repr(M, width=8))
            row.append(np.binary_repr(R, width=12))
            col.append(np.binary_repr(C, width=12))
    print(row_tp)
    print(row)
    for i in range(len(row)):
        if i == len(row) - 1 or row[i] != row[i + 1]:
            ipv.append(np.binary_repr(1, width=1))
        else:
            ipv.append(np.binary_repr(0, width=1))
    print(ipv)
    for i in range((4 - len(mat) % 4) % 4): # keep the data size the factor of 4
        mat.append(np.binary_repr(0, width=8))
        row.append(np.binary_repr(0, width=12))
        col.append(np.binary_repr(0, width=12))
        ipv.append(np.binary_repr(0, width=1))
    
    for i in range(len(ipv) // 4):
        cnt1 = 0
        for j in range(4 * i, 4 * (i + 1)):
            if ipv[j] == 1:
                cnt1 = cnt1 + 1
        VOV = ''
        for j in range(cnt1):
            VOV = VOV + '1'
        for j in range(4 - cnt1):
            VOV = VOV + '0'
        
        vov.append(VOV)
    output = matrix.dot(vector)
    print(matrix)
    print(vector)
    print(output)
    
    ans = []
    for ele in output:
        ans.append(np.binary_repr(ele, width=28))
    
    vec = []
    for ele in vector:
        vec.append(np.binary_repr(ele, width=8))

    return np.array(vec), np.array(mat), np.array(col), np.array(ipv), np.array(vov), np.array(ans)

def writeData(vector, matrix, column, ipv, vov, ans):
    np.savetxt(vector_path, vector, fmt='%s')
    np.savetxt(matrix_path, matrix, fmt='%s')
    np.savetxt(columnIndex_path, column, fmt='%s')
    np.savetxt(ipv_path, ipv, fmt='%s')
    np.savetxt(vov_path, vov, fmt='%s')
    np.savetxt(golden_path, ans, fmt='%s')

if __name__ == '__main__':
    np.random.seed(0)
    matrix = generate_matrix()
    vector = generate_vector()
    vec, ele, col, ipv, vov, ans = solve(matrix, vector)
    writeData(vec, ele, col, ipv, vov, ans)

    