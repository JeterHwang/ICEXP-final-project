import numpy as np

matrix_path = '../dat/matrix_in.dat'
columnIndex_path = '../dat/columnIndex_in.dat'
vector_path = '../dat/vector_in.dat'
vov_path = '../dat/vov_out.dat'

data_range = np.ndarray([-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
probability = np.ndarray([0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.5,
                          0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025, 0.025])
array_size = 128

def generate_matrix():
    return np.random.choice(data_range, (array_size, array_size), probability)

def generate_vector():
    return np.random.choice(data_range, array_size, probability)

def solve(matrix):
    list1 = []
    ipv = []

    for i in range(array_size):
        for j in range(array_size):
            if matrix[i][j] != 0:
                list1.append((matrix[i][j], i, j))
    for i in range(len(list1)):
        
        

def writeData(vecotr, matrix, ipv, vov):
    with open(matrix_path, 'w') as f1, open(columnIndex_path, 'w') as f2, open(vector_path, 'w') as f3, open(vov_path, 'w') as f4:
        f1.write()
        f2.write()
        f3.write()
        f4.write()


if __name__ == '__main__':
    matrix = generate_matrix()
    vecotr = generate_vector()
    ele, ipv, vov = solve(matrix)
    writeData(ele, )

    