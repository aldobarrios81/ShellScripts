#!/bin/bash
echo "Script is starting..."
CTIME=$(date +"%Y-%m-%d_%H-%M-%S")
iDate=$(date +"%y%m%d%H" -d "$2" 2>/dev/null)
if ! [ $? -eq 0 ]; then
    echo "Error: Wrong initial date"
    exit 1
fi
eDate=$(date +"%y%m%d%H" -d "$3" 2>/dev/null)
if ! [ $? -eq 0 ]; then
    echo "Error: Wrong final date"
    exit 1
fi
Node=$4
WorkingMode=$(echo $1 | tr '[:upper:]' '[:lower:]')
file_path=/logs/top_output
LOG=/logs/TOPAD_output
host=$(/bin/hostname)
case $WorkingMode in
"node")

    if [ "$4" = "" ]; then
        echo "Error: Enter valid node name as 4th argument"
        exit 1
    fi
    echo "Input files from path /logs/top_output/, starting analysis as node working mode"
    echo "Date","Time","PID","res", "CPU", "Mem" >$LOG/${host}_${Node}_process_analysis_$CTIME.csv
    for f in $(/bin/ls -l $file_path/ | /bin/awk '{
	name=substr($9,0,8); 
	if(name >= '$iDate' && name <= '$eDate'){print $9}}'); do
        /bin/awk '$1=="top"{
         time=$3
      }$12 ~ /'$Node'/{
       unit=substr($6,length($6),1);

       switch(unit) {
         case /g|G/:
         f=1;
         break;
       case /m|M/:
         f=1/1024;
         break;
       case /t|T/:
         f=1024;
         break;
       default:
         f=1/1024/1024;
         break;
      }
      pid=$1
      print pid > "/tmp/pid.tmp"
      res=substr($6,0,length($6)-1)*f;
      a[time","pid]=res","$9","$10;
     }END{
      OFS=",";
      for(k in a){
        print substr(FILENAME,18,6),k,a[k] | "sort -k2"
      }
    }' $file_path/$f >>$LOG/${host}_${Node}_process_analysis_$CTIME.csv
    done
    #if ["cat /tmp/pid.tmp" = "No such file or directory"] then;
    #echo "invalid Node name in 4th argument"
    #exit 1
    #fi
    echo "The pid(s) related to this node were: "
    cat /tmp/pid.tmp | sort | uniq
    echo "The node analysis has been completed successfully"
    echo "The output file was saved in $LOG/${host}_${Node}_process_analysis_$CTIME.csv"
    ;;
"server")
    if [[ $4 != "" ]]; then
        echo "Error: invalid argument, only 3 arguments are needed"
        exit 1
    fi
    echo "Inputs files from /logs/top_output/, starting analysis as server working mode"
    echo "Date", "Time", "CPU_IDLE", "io", "st", "total_mem", "used_mem", "free_mem", "Load1", "Load2", "Load3" >$LOG/${host}_server_top_analysis_$CTIME.csv
    for f in $(/bin/ls -l $file_path/ | /bin/awk '{name=substr($9,0,8);
	 if(name >= '$iDate' && name <= '$eDate' ){print $9}}'); do
        /bin/awk '$1=="top" {		
 	   time=$3; l1=substr($13,0,length($13)-1); l2=substr($14,0,length($14)-1); l3=substr($15,0,length($15)-1)};
	   $11=="wa," {i=$8; w=$10; s=$16}; 
	   $2=="Mem" {a[time]=i","w","s","$4","$6","$8","l1","l2","l3}
        END{
	   OFS=","; 
	   for(k in a){print substr(FILENAME,18,6),k,a[k]| "sort -k2"
        }
      }' $file_path/$f >>$LOG/${host}_server_top_analysis_$CTIME.csv
    done

    echo "The server analysis has been completed successfully"
    echo "The output file was saved in $LOG/${host}_server_top_analysis_$CTIME.csv"
    ;;
"--help")
    echo "TopAd Help"
    echo "=========="
    echo "command syntax is as follows"
    echo "sh TopAD < Working mode > < Initial Date & Hour> < End Date & Hour> < Node name >"
    echo "This command is using four parameters which are the following:"
    echo " 1) Working mode, which can be server or node"
    echo " 2) Initial date and hour, which can be in any valid date format like YY/MM/DD HH"
    echo " 3) Final date and hour, which can be in any valid date format like YY/MM/DD HH"
    echo " 4) Node name, which only needed in when Working mode is node"
    ;;
*)
    echo "Error: Wrong working mode"
    ;;
esac
rm -f /tmp/pid.tmp
