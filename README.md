# ICEXP-final-project

## Branch
1. clone repo
```
cd [the folder you want the repo to be]
git clone https://github.com/JeterHwang/ICEXP-final-project.git 
```

## Source Command
```
source /usr/cad/cadence/cshrc
source /usr/cad/synopsys/CIC/verdi.cshrc
source /usr/cad/synopsys/CIC/synthesis.cshrc
source /usr/cad/innovus/CIC/license.cshrc
source /usr/cad/innovus/CIC/innovus.cshrc
```

## test Command
```
cd tb

RTL : ncverilog SMVM_tb.v +define+RTL +access+r
SYN : ncverilog SMVM_tb.v -v fsa0m_a_generic_core_21.lib.src +define+SYN +access+r
APR : ncverilog SMVM_tb.v -v fsa0m_a_generic_core_21.lib.src fsa0m_a_t33_generic_io_21.lib.src +define+APR +access+r
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
        
    col : 8 bit (no need to have this port !!)

    clk : 1 bit
    rst : 1 bit

    ====== output =======
    data_o : 12 bit + 12 bit
    
```

## APR command
```
setAnalysisMode -analysisType bcwc
write_sdf -max_view av_func_mode_max -min_view av_func_mode_min -edges noedge -splitsetuphold -remashold -splitrecrem -min_period_edges none SMVM_apr.sdf

add_text -layer metal5 -pt 1435 640 -label IOVDD -height 10
add_text -layer metal5 -pt 1435 750 -label IOVSS -height 10

setStreamOutMode -specifyViaName default -SEvianames false -virtualConnection false -uniquifyCellNamesPrefix false -snapToMGrid false -textSize 1 -version 3
streamOut SMVM_apr.gds -mapFile streamOut.map -merge {./Phantom/fsa0m_a_generic_core_cic.gds ./Phantom/fsa0m_a_t33_generic_io_cic.gds ./Phantom/BONDPAD.gds} -stripes 1 -unit 1000 -mode ALL
```

## LVS command
```
source /usr/mentor/CIC/calibre.cshrc
v2lvs -l core.v -l umc18_io_lvs.v -s core.spi -s umc18_io_lvs.spi -v CHIP.v -o CHIP.spi
calibre -lvs -hier -auto G-DF-MIXED_MODE_RFCMOS18-1.8V_3.3V-1P6M-MMC_CALIBRE-LVS-2.1-P8.txt
```