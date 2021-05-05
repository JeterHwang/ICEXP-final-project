import numpy as np
import os
from os import path

vector_path = '../dat/vector_in.dat'
matrix_path = '../dat/matrix_in.dat'
columnIndex_path = '../dat/columnIndex_in.dat'
ipv_path = '../dat/ipv_in.dat'
vov_path = '../dat/vov_out.dat'

data_range = np.array([-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
probability_matrix = np.array([0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.5,
                          0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025])
probability_vector = np.array([0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.0, 
                          0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05])
array_size = 128

def generate_matrix():
    return np.random.choice(data_range, (array_size, array_size), p=probability_matrix)

def generate_vector():
    return np.random.choice(data_range, array_size, p=probability_vector)

def solve(matrix):
    mat = []
    row = []
    col = []
    ipv = []
    vov = []

    for i in range(array_size):
        for j in range(array_size):
            if matrix[i][j] != 0:
                mat.append(matrix[i][j])
                row.append(i)
                col.append(j)
    for i in range(len(row)):
        if i == len(row) - 1 or row[i] != row[i + 1]:
            ipv.append(1)
        else:
            ipv.append(0)
    
    for i in range((4 - len(mat) % 4) % 4):
        mat.append(0)
        row.append(0)
        col.append(0)
        ipv.append(0)
    
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

    return np.array(mat), np.array(col), np.array(ipv), np.array(vov)


        
def writeData(vecotr, matrix, column, ipv, vov):
    np.savetxt(vector_path, vector.astype(int), fmt='%d')
    np.savetxt(matrix_path, matrix.astype(int), fmt='%d')
    np.savetxt(columnIndex_path, column.astype(int), fmt='%d')
    np.savetxt(ipv_path, ipv.astype(int), fmt='%d')
    np.savetxt(vov_path, vov, fmt='%s')

if __name__ == '__main__':
    matrix = generate_matrix()
    vector = generate_vector()
    ele, col, ipv, vov = solve(matrix)
    writeData(vector, ele, col, ipv, vov)

    