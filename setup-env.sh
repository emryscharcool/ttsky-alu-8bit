#!/bin/bash

echo "Initializing PDK-SKY130A...."
echo "Initializing OPENLANE..."
echo "Initializing Environment Variables"
echo ""
export PATH="$HOME/.local/bin:$PATH"
install_dir=/home/tools
caravel_dir_name=caravel_user_project

export PDK_ROOT=$install_dir/pdk
export OPENLANE_ROOT=$install_dir/openlane
export PDK=sky130A

export MGMT_AREA_ROOT=$install_dir/$caravel_dir_name/mgmt_core_wrapper
export DESIGNS=$install_dir/$caravel_dir_name
export TARGET_PATH=$DESIGNS
export CARAVEL_ROOT=$DESIGNS/caravel 
export MCW_ROOT=$DESIGNS/mgmt_core_wrapper 
export CORE_VERILOG_PATH=$MCW_ROOT/verilog
export PATH=$PATH:$install_dir/oss-cad-suite/bin
export GCC_PATH=$install_dir/riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14/bin/
export PATH=$PATH:$GCC_PATH
export GCC_PREFIX=riscv64-unknown-elf
export PATH=$PATH:$install_dir/openlane_summary/
git --version
python3 --version
magic --version
echo ""
ngspice --version
echo ""
tabbyadm version
echo ""
riscv64-unknown-elf-gcc --version
echo ""

echo "Initialization complete!"
