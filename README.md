# ICEXP-final-project

## Branch
1. clone repo
```
cd [the folder you want the repo to be]
git clone https://github.com/JeterHwang/ICEXP-final-project.git 
```

## Source Command
```
>	source /usr/cad/cadence/cshrc
>	source /usr/cad/synopsys/CIC/verdi.cshrc
>	source /usr/cad/synopsys/CIC/synthesis.cshrc
```

## Pattern Generating
1. generate data
```
tb/dat/matrix_in.dat
tb/dat/vector_in.dat
tb/dat/ipv_in.dat
tb/dat/columnIndex_in.dat
tb/dat/vov_out.dat
```
3. command 
```
cd tb/python
python3 generate.py
```

## File structure
```
.
+-- README.md
+-- src
|   +-- adderAccumulator.v
|   +-- IPV_reducer.v
|   +-- SMVM.v
|   +-- ALU_maple.v
+-- tb
|   +-- aac_tb.v
|   +-- reudcer_tb.v
|   +-- ALU_tb.v
|   +-- python
|   |   +-- generate.py
|   +-- dat
|   |   +-- aac_ans.dat
|   |   +-- aac_data1.dat
|   |   +-- aac_data2.dat
|   |   +-- columnIndex.dat
|   |   +-- matrix_in.dat
|   |   +-- vector_in.dat
|   |   +-- ipv_in.dat
|   |   +-- vov_out.dat
```
## 5/14 Notice
```
1. bit change
    ======= input =======
    ipv : 1 bit
        +
    val : 8 bit
        ||
    col : 9 bit (no need to have this port !!)

    clk : 1 bit
    rst : 1 bit

    ====== output =======
    data_o : 13 bit + 13 bit
    
```
