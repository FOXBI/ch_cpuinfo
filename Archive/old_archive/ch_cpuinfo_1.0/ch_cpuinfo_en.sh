#!/bin/bash
# Ver 1.0 2018.08.17 Made by FOXBI
# ==============================================================================
# Y or N Function
# ==============================================================================
READ_YN () { # $1:question $2:default
   read -n1 -p "$1" Y_N
    case "$Y_N" in
    y) Y_N="y"
         echo -e "\n" ;;
    n) Y_N="n"
         echo -e "\n" ;;        
    q) echo -e "\n"
       exit 0 ;;
    *) echo -e "\n" ;;
    esac
   
}

# ==============================================================================
# Color Function
# ==============================================================================
cecho() {
    if [ -n "$3" ]
    then
        case "$3" in
            black  | bk) bgcolor="40";;
            red    |  r) bgcolor="41";;
            green  |  g) bgcolor="42";;
            yellow |  y) bgcolor="43";;
            blue   |  b) bgcolor="44";;
            purple |  p) bgcolor="45";;
            cyan   |  c) bgcolor="46";;
            gray   | gr) bgcolor="47";;
        esac        
    else
        bgcolor="0"
    fi
    code="\033["
    case "$1" in
        black  | bk) color="${code}${bgcolor};30m";;
        red    |  r) color="${code}${bgcolor};31m";;
        green  |  g) color="${code}${bgcolor};32m";;
        yellow |  y) color="${code}${bgcolor};33m";;
        blue   |  b) color="${code}${bgcolor};34m";;
        purple |  p) color="${code}${bgcolor};35m";;
        cyan   |  c) color="${code}${bgcolor};36m";;
        gray   | gr) color="${code}${bgcolor};37m";;
    esac

    text="$color$2${code}0m"
    echo -e "$text"
}

# ==============================================================================
# Process Function
# ==============================================================================
PREPARE_FN () {
    if [ -f "$WORK_DIR/admin_center.js" ]
    then
        if [ "$direct_job" == "y" ]
        then
            cecho r "warning!! Work directly on the original file without backup.\n"
        else    
            tar -cf $BKUP_DIR/$TIME/admin_center.tar admin_center.js*
        fi
        if [ "$MA_VER" -eq "6" ] && [ "$MI_VER" -ge "2" ]
        then
            mv $WORK_DIR/admin_center.js.gz $BKUP_DIR/
	        cd $BKUP_DIR/
            gzip -df $BKUP_DIR/admin_center.js.gz        
        else
            cp -Rf $WORK_DIR/admin_center.js $BKUP_DIR/
        fi
    else
        COMMENT08_FN
        exit 0
    fi
}

GATHER_FN () {
    cpu_vendor=`dmidecode -t processor | grep Version | grep -v Unknown | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{print $2}'`
    cpu_family=`dmidecode -t processor | grep Version | grep -v Unknown | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{print $3}'`
    if [ "$cpu_vendor" == "AMD" ]
    then
        cpu_series=`dmidecode -t processor | grep Version | grep -v Unknown | grep -v Not | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk -F "Version: " '{ print $2 }' | awk -F "Processor" '{ print $1 }'`
    else
        cpu_series=`dmidecode -t processor | grep Version | grep -v Unknown | grep -v Not | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{ if (index($5,"@")!=0) { print $4 } else { print $4" "$5 } }'`
    fi
    cpu_cores=`cat /proc/cpuinfo | grep processor| wc -l`
}

PERFORM_FN () {
    if [ -f "$BKUP_DIR/admin_center.js" ]
    then    
        if [ "$MA_VER" -ge "6" ]
        then
            cpu_info=`echo "f.cpu_vendor=\"${cpu_vendor}\";f.cpu_family=\"${cpu_family}\";f.cpu_series=\"${cpu_series}\";f.cpu_cores=\"${cpu_cores}\";"`
            sed -i "s/f.model]);/f.model]);${cpu_info}/g" $BKUP_DIR/admin_center.js
        else
            if [ "$MI_VER" -gt "0" ]
            then
                cpu_info=`echo "b.cpu_vendor=\"${cpu_vendor}\";b.cpu_family=\"${cpu_family}\";b.cpu_series=\"${cpu_series}\";b.cpu_cores=\"${cpu_cores}\";"`
            else
                cpu_info=`echo "b.cpu_vendor=\"${cpu_vendor}\";b.cpu_family=\"${cpu_family}${cpu_series}\";b.cpu_cores=\"${cpu_cores}\";"`
            fi
            sed -i "s/b.model]);/b.model]);${cpu_info}/g" $BKUP_DIR/admin_center.js
        fi
    else
        COMMENT08_FN
        exit 0
    fi
}

APPLY_FN () {
    if [ -f "$BKUP_DIR/admin_center.js" ]
    then    
        cp -Rf $BKUP_DIR/admin_center.js $WORK_DIR/
        if [ "$MA_VER" -eq "6" ] && [ "$MI_VER" -ge "2" ]
        then    
            gzip $BKUP_DIR/admin_center.js
            mv $BKUP_DIR/admin_center.js.gz $WORK_DIR/
        fi
    else
        COMMENT08_FN
        exit 0
    fi        
}

RECOVER1_FN () {
    if [ "$Y_N" == "y" ]    
    then
        RECOVER2_FN
    elif [ "$Y_N" == "n" ]
    then
        echo "No recovery was performed."   
    else
        COMMENT10_FN
    fi
}

RECOVER2_FN () {
    if [ -d "$BKUP_DIR/$TIME" ]
    then
        cd $WORK_DIR
        tar -xf $BKUP_DIR/$TIME/admin_center.tar
        if [ "$re_check" == "y" ]
        then
            echo -e "Restore to source and continue.\n"
        else
            COMMENT09_FN
        fi
    else
        COMMENT08_FN
        exit 0
    fi
}

EXEC_FN () {
if [ -d $WORK_DIR ]
then    
    READ_YN "Auto Excute, If you select n, proceed interactively  (Cancel : q) [y/n] : "
    if [ "$Y_N" == "y" ]
    then
        mkdir -p $BKUP_DIR/$TIME
        cd $WORK_DIR

        if [ "$re_check" == "y" ]
        then
            RECOVER2_FN
        fi

        PREPARE_FN

        GATHER_FN

        PERFORM_FN

        APPLY_FN

        COMMENT09_FN

    elif [ "$Y_N" == "n" ]
    then
        READ_YN "Proceed with original file backup and preparation.. If you select n, Work directly on the original file. (Cancel : q) [y/n] : "
        if [ "$Y_N" == "y" ]    
        then
            mkdir -p $BKUP_DIR/$TIME
		    cd $WORK_DIR

            if [ "$re_check" == "y" ]
            then
 		        RECOVER2_FN
            fi

            PREPARE_FN

        elif [ "$Y_N" == "n" ]
        then
            direct_job=y
            mkdir -p $BKUP_DIR
            PREPARE_FN            
        else
            COMMENT10_FN
        fi

        READ_YN "CPU name, Core count and reflects it. If you select n, Resote original file (Cancel : q) [y/n] : "
        if [ "$Y_N" == "y" ]    
        then    
            GATHER_FN

            PERFORM_FN

            APPLY_FN

		    COMMENT09_FN
        elif [ "$Y_N" == "n" ]
        then
	        if [ -d "$BKUP_DIR" ]
    	    then
                gzip $BKUP_DIR/admin_center.js
                mv $BKUP_DIR/admin_center.js.gz $WORK_DIR/
		    else
			    COMMENT07_FN
		    fi
        else
            COMMENT10_FN
        fi
    else
        COMMENT10_FN
    fi
else
    COMMENT08_FN
fi
}

COMMENT07_FN () {
    echo "No execution history. Please go back to the first run."
    exit 0
}

COMMENT08_FN () {
    echo "The target file(location) does not exist. Please run again after checking."
    exit 0
}

COMMENT09_FN () {
    echo "The operation is complete!! It takes about 1-2 minutes to reflect, please refresh the DSM page with F5 and check the information."
    exit 0
}

COMMENT10_FN () {
    echo "Only y / n / q can be input. Please proceed again."
    exit 0
}

# ==============================================================================
# Main Progress
# ==============================================================================
clear
TIME=`date +%Y%m%d%H%M%S`
WORK_DIR="/usr/syno/synoman/webman/modules/AdminCenter"
BKUP_DIR="/root/Xpenology_backup"
VER_DIR="/etc.default"

if [ -d "$VER_DIR" ]
then
    VER_FIL="$VER_DIR/VERSION"
else
    VER_FIL="/etc/VERSION"
fi

if [ -f "$VER_FIL" ]
then
    MA_VER=`cat $VER_FIL | grep majorversion | awk -F \= '{print $2}' | sed 's/\"//g'`
    MI_VER=`cat $VER_FIL | grep minorversion | awk -F \= '{print $2}' | sed 's/\"//g'`
else
    COMMENT08_FN
fi

if [ "$MA_VER" -gt "4" ]
then
    cecho g "Your version of DSM is \033[0;34mDSM \033[0;31m"$MA_VER"."$MI_VER"\033[0;32m continue...\n"
else
    echo "DSM version less than 5 is not supported. End the process."
    exit 0
fi

read -n1 -p "1) First run  2) Redo  3) Restore - Select Number : " inst_z 
   case "$inst_z" in
   1) inst_check=install 
      echo -e "\n " ;;
   2) inst_check=reinstall 
      echo -e "\n " ;;
   3) inst_check=recovery 
      echo -e "\n " ;;
   *) echo -e "\n" ;;
   esac

if [ "$inst_check" = "reinstall" ]
then
	READ_YN "Do you want to proceed again? Restore to original file backup and proceed.(Cancel : q) [y/n] : "
    inst_check=install
    re_check=y
    if [ -d "$BKUP_DIR" ]
    then
        TIME=`ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1`
    else
        COMMENT07_FN
        exit 0
    fi

    if [ "$Y_N" == "y" ]    
    then        
        EXEC_FN
    elif [ "$Y_N" == "n" ]
    then
        echo "Do not proceed with the redo."    
    else
        COMMENT10_FN
    fi
elif [ "$inst_check" = "recovery" ]
then
	READ_YN "Do you want to restore using the original backup file? (Cancel : q) [y/n] : "
    re_check=n
    if [ -d "$BKUP_DIR" ]
    then    
        TIME=`ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1`    
    else
        COMMENT07_FN
        exit 0
    fi
    RECOVER1_FN
elif [ "$inst_check" = "install" ]
then
    re_check=n
    EXEC_FN
else
    echo "Please select the correct number."
fi