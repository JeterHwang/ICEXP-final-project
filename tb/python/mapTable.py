import numpy as np
import math

def generate_N(k):
    K = k
    N = [0]
    for i in range(1, math.ceil(math.log2(k)) + 1 + 1):
        N.append(K >> 1)
        K = (K >> 1) + (K & 1)
    return np.array(N)

def make_table(k, N):
    T = np.zeros(((1<<(k-1)) + 1, 2 * (k-1) + k * math.ceil(math.log2(k)) + k + 1))

    for ipv in range((1<<(k-1))):
        B1 = np.array([int(ele) for ele in np.binary_repr(ipv, width=k-1)] + [1])
        B2 = np.zeros(k + 1)
        S1 = np.array([ele for ele in range(1, k+1)])
        S2 = np.zeros(k + 1)

        i_in_s  = 1
        lB1     = k

        for level in range(1, math.ceil(math.log2(k)) + 1 + 1):
            i_B1 = 0
            i_B2 = 0

            i_out_a = 1
            i_out_r = N[level] + 1
            
            i_in_a = i_in_s
            i_in_r = i_in_s + 2 * N[level]

            while i_B1 < lB1:
                if level == (math.ceil(math.log2(k)) + 1) and i_B1 == lB1 - 1:
                    T[ipv][3 * k - 2 + k * math.ceil(math.log2(k))] = S1[i_B1]
                    S2[i_B2]        = k
                    B2[i_B2]        = B1[i_B1]
                    i_out_r         = i_out_r + 1
                    i_in_r          = i_in_r + 1
                    i_B1            = i_B1 + 1
                    i_B2            = i_B2 + 1
                elif B1[i_B1] == 1 or i_B1 == lB1 - 1:
                    T[ipv][i_in_r]  = S1[i_B1]
                    S2[i_B2]        = i_out_r
                    B2[i_B2]        = B1[i_B1]
                    i_out_r         = i_out_r + 1
                    i_in_r          = i_in_r + 1
                    i_B1            = i_B1 + 1
                    i_B2            = i_B2 + 1
                else:
                    T[ipv][i_in_a]  = S1[i_B1]
                    T[ipv][i_in_a + 1] = S1[i_B1 + 1]
                    S2[i_B2]        = i_out_a
                    B2[i_B2]        = B1[i_B1 + 1]
                    i_in_a          = i_in_a + 2
                    i_B1            = i_B1 + 2
                    i_out_a         = i_out_a + 1
                    i_B2            = i_B2 + 1
            
            print(T)
            print(S1)
            print(S2)
            print(B1)
            print(B2)
            

            i_in_s  = i_in_s + 2 * N[level] + k
            B1      = B2
            lB1     = i_B2
            S1      = S2

            print(lB1)
            print()
            
    return T

if __name__ == '__main__':
    k = 4
    N = generate_N(k)
    print(N)
    print(make_table(k, N))