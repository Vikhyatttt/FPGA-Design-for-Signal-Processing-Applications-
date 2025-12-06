# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/grads/t/tamu_vik/ECEN-722/lab4/top_fft_time/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/grads/t/tamu_vik/ECEN-722/lab4/top_fft_time/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {top_fft_time}\
-hw {/home/grads/t/tamu_vik/ECEN-722/lab4/top_fft_time.xsa}\
-out {/home/grads/t/tamu_vik/ECEN-722/lab4}

platform write
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {zynq_fsbl}
platform generate -domains 
platform active {top_fft_time}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
platform generate
