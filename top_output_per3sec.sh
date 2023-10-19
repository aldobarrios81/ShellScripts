#!/bin/bash
REMAIN=60
INC=5
while [  $REMAIN -gt 0 ]; do

output_file_path=/logs/top_output/


time_prefix=`date +%y%m%d%H`
current_min=`date +"%T"`
echo "-------------------------------------------------------------------------------------------  $current_min ----------------------------------------------------------------------------"  >>  $output_file_path$time_prefix"_top_output.txt"
COLUMNS=1000 top  -c  -bn1 | head -30 >>  $output_file_path$time_prefix"_top_output.txt"
#sleep 29

        sleep $INC
        REMAIN=$(($REMAIN - $INC))
done
find $output_file_path -mtime +14 -exec rm -f {} \;
