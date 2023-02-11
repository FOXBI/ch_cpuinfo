#!/bin/sh
ver="1.0.0-b01"
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
    if [ -f "$WORK_DIR/admin_center.js" ] && [ -f "$MWORK_DIR/mobile.js" ]
    then
        if [ "$direct_job" == "y" ]
        then
            cecho r "경고!! 백업하지 않고 원본에 직접 작업합니다.\n"
        else
            cd $WORK_DIR
            tar -cf $BKUP_DIR/$TIME/admin_center.tar admin_center.js*
            cd $MWORK_DIR
            tar -cf $BKUP_DIR/$TIME/mobile.tar mobile.js*
        fi
        if [ "$MA_VER" -eq "6" ] && [ "$MI_VER" -ge "2" ]
        then
            mv $WORK_DIR/admin_center.js.gz $BKUP_DIR/
            mv $MWORK_DIR/mobile.js.gz $BKUP_DIR/
	        cd $BKUP_DIR/
            gzip -df $BKUP_DIR/admin_center.js.gz 
            gzip -df $BKUP_DIR/mobile.js.gz        
        else
            cp -Rf $WORK_DIR/admin_center.js $BKUP_DIR/
            cp -Rf $MWORK_DIR/mobile.js $BKUP_DIR/
        fi
    else
        COMMENT08_FN
    fi
}

GATHER_FN () {
    if [ -f "/sbin/dmidecode" ]
    then
        DMI_CHK=`dmidecode | grep 'SMBIOS' | egrep 'NO|sorry' | wc -l`
    else
        DMI_CHK="1"
    fi
    if [ "$DMI_CHK" -gt "0" ]
    then
        cpu_vendor=`cat /proc/cpuinfo | grep model | grep name | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{print $4}'`
        if [ "$cpu_vendor" == "AMD" ]
        then
            cpu_family=`cat /proc/cpuinfo | grep model | grep name | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk -F "$cpu_vendor " '{ print $2 }' | awk -F "Processor" '{ print $1 }'`
            cpu_series=""
        else
            cpu_family=`cat /proc/cpuinfo | grep model | grep name | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{print $5}'`        
            cpu_series=`cat /proc/cpuinfo | grep model | grep name | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{ if (index($7,"@")!=0) { print $6 } else { print $6" "$7 } }'`
        fi        
    else
        cpu_vendor=`dmidecode -t processor | grep Version | grep -v Unknown | grep -v Not | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{print $2}'`
        if [ "$cpu_vendor" == "AMD" ]
        then
            cpu_family=`dmidecode -t processor | grep Version | grep -v Unknown | grep -v Not | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk -F "$cpu_vendor " '{ print $2 }' | awk -F "Processor" '{ print $1 }'`
            cpu_series=""
        else
            cpu_family=`dmidecode -t processor | grep Version | grep -v Unknown | grep -v Not | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{print $3}'`        
            cpu_series=`dmidecode -t processor | grep Version | grep -v Unknown | grep -v Not | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | awk '{ if (index($5,"@")!=0) { print $4 } else { print $4" "$5 } }'`
        fi
    fi
    PICNT=`cat /proc/cpuinfo | grep "^physical id" | sort -u | wc -l`
    CICNT=`cat /proc/cpuinfo | grep "^core id" | sort -u | wc -l`
    CCCNT=`cat /proc/cpuinfo | grep "^cpu cores" | sort -u | awk '{print $NF}'`
    CSCNT=`cat /proc/cpuinfo | grep "^siblings" | sort -u | awk '{print $NF}'`
    THCNT=`cat /proc/cpuinfo | grep "^processor" | wc -l`
    ODCNT=`cat /proc/cpuinfo | grep "processor" | wc -l`
    if [ "$THCNT" -gt "0" ] && [ "$PICNT" == "0" ] && [ "$CICNT" == "0" ] && [ "$CCCNT" == "" ] && [ "$CSCNT" == "" ]
    then
        PICNT="1"
        CICNT="$THCNT"
        CCCNT="$THCNT"
        CSCNT="$THCNT"
    fi
    if [ "$PICNT" -gt "1" ]
    then
        TPCNT="$PICNT CPUs"
        TCCNT=`expr $PICNT \* $CCCNT`
    else
        TPCNT="$PICNT CPU"
        TCCNT="$CCCNT"
    fi
    if [ "$TCCNT" -gt "1" ]
    then
        TCCNT="$TCCNT Cores "
    else
        TCCNT="$TCCNT Core "
    fi
    if [ "$CCCNT" -gt "1" ]
    then
        PCCNT="\/$CCCNT Cores "
    else
        PCCNT=" "
    fi    
    if [ "$THCNT" -gt "1" ]
    then
        TTCNT="$THCNT Threads"
    else
        TTCNT="$THCNT Thread"
    fi
    cpu_cores="$TCCNT($TPCNT$PCCNT| $TTCNT)"
}

PERFORM_FN () {
    if [ -f "$BKUP_DIR/admin_center.js" ] && [ -f "$BKUP_DIR/mobile.js" ]
    then    
        if [ "$MA_VER" -ge "6" ]
        then
            cpu_info=`echo "${dt}.cpu_vendor=\"${cpu_vendor}\";${dt}.cpu_family=\"${cpu_family}\";${dt}.cpu_series=\"${cpu_series}\";${dt}.cpu_cores=\"${cpu_cores}\";"`
            sed -i "s/${dt}.model]);/${dt}.model]);${cpu_info}/g" $BKUP_DIR/admin_center.js

            cpu_info_m=`echo "{name: \"cpu_series\",renderer: function(value){var cpu_vendor=\"${cpu_vendor}\";var cpu_family=\"${cpu_family}\";var cpu_series=\"${cpu_series}\";var cpu_cores=\"${cpu_cores}\";return Ext.String.format('{0} {1} {2} [ {3} ]', cpu_vendor, cpu_family, cpu_series, cpu_cores);},label: _T(\"status\", \"cpu_model_name\")},"`
            sed -i "s/\"ds_model\")},/\"ds_model\")},${cpu_info_m}/g" $BKUP_DIR/mobile.js
        else
            if [ "$MI_VER" -gt "0" ]
            then
                cpu_info=`echo "${dt}.cpu_vendor=\"${cpu_vendor}\";${dt}.cpu_family=\"${cpu_family}\";${dt}.cpu_series=\"${cpu_series}\";${dt}.cpu_cores=\"${cpu_cores}\";"`
            else
                cpu_info=`echo "${dt}.cpu_vendor=\"${cpu_vendor}\";${dt}.cpu_family=\"${cpu_family} ${cpu_series}\";${dt}.cpu_cores=\"${cpu_cores}\";"`
            fi
            sed -i "s/${dt}.model]);/${dt}.model]);${cpu_info}/g" $BKUP_DIR/admin_center.js
        fi
    else
        COMMENT08_FN
    fi
}

APPLY_FN () {
    if [ -f "$BKUP_DIR/admin_center.js" ] && [ -f "$BKUP_DIR/mobile.js" ]
    then    
        cp -Rf $BKUP_DIR/admin_center.js $WORK_DIR/
        cp -Rf $BKUP_DIR/mobile.js $MWORK_DIR/
        if [ "$MA_VER" -eq "6" ] && [ "$MI_VER" -ge "2" ]
        then    
            gzip -f $BKUP_DIR/admin_center.js
            gzip -f $BKUP_DIR/mobile.js
            mv $BKUP_DIR/admin_center.js.gz $WORK_DIR/
            mv $BKUP_DIR/mobile.js.gz $MWORK_DIR/
        else
            rm -rf $BKUP_DIR/admin_center.js
            rm -rf $BKUP_DIR/mobile.js
        fi
    else
        COMMENT08_FN
    fi        
}

RECOVER_FN () {
    if [ -d "$BKUP_DIR/$TIME" ]
    then
        cd $WORK_DIR
        tar -xf $BKUP_DIR/$TIME/admin_center.tar
        if [ -f "$BKUP_DIR/$TIME/mobile.tar" ]
        then
            cd $MWORK_DIR
            tar -xf $BKUP_DIR/$TIME/mobile.tar
        fi
        if [ "$re_check" == "y" ]
        then
            echo -e "원본으로 복구후 계속 수행합니다.\n"
        else
            COMMENT09_FN
        fi
    else
        COMMENT08_FN
    fi
}

RERUN_FN () {
    if [ "$1" == "redo" ]
    then
        ls -l $BKUP_DIR/ | grep ^d | grep -v "$BL_CHK" | awk '{print "rm -rf '$BKUP_DIR'/"$9}' | sh
        GATHER_FN
        if [ -f "$WORK_DIR/admin_center.js" ] && [ -f "$MWORK_DIR/mobile.js" ]
        then
            info_cnt=`cat $WORK_DIR/admin_center.js | grep ".model]);if(Ext.isDefined" | wc -l`
            info_cnt_m=`cat $MWORK_DIR/mobile.js | grep "ds_model\")},{name:\"ram_size" | wc -l`
            if [ "$info_cnt" -eq "0" ] && [ "$info_cnt_m" -eq "0" ]
            then
                ODCNT_CHK=`cat $WORK_DIR/admin_center.js | grep "cpu_cores=\"$ODCNT\"" | wc -l`
                if [ "$ODCNT_CHK" -gt "0" ]
                then
                    cpu_cores="$ODCNT"
                fi                        
                if [ "$MA_VER" -ge "6" ]
                then
                    cpu_info="${dt}.cpu_vendor=\\\"${cpu_vendor}\\\";${dt}.cpu_family=\\\"${cpu_family}\\\";${dt}.cpu_series=\\\"${cpu_series}\\\";${dt}.cpu_cores=\\\"${cpu_cores}\\\";"
                    sed -i "s/${cpu_info}//g" $WORK_DIR/admin_center.js

                    ODCNT_CHK=`cat $MWORK_DIR/mobile.js | grep "cpu_cores=\"$ODCNT\"" | wc -l`
                    if [ "$ODCNT_CHK" -gt "0" ]
                    then
                        cpu_cores="$ODCNT"
                    fi                    

                    cpu_info_m="{name: \\\"cpu_series\\\",renderer: function(value){var cpu_vendor=\\\"${cpu_vendor}\\\";var cpu_family=\\\"${cpu_family}\\\";var cpu_series=\\\"${cpu_series}\\\";var cpu_cores=\\\"${cpu_cores}\\\";return Ext.String.format('{0} {1} {2} [ {3} ]', cpu_vendor, cpu_family, cpu_series, cpu_cores);},label: _T(\\\"status\\\", \\\"cpu_model_name\\\")},"
                    sed -i "s/${cpu_info_m}//g" $MWORK_DIR/mobile.js                    
                    if [ "$MI_VER" -ge "2" ]
                    then
                        cp -Rf $WORK_DIR/admin_center.js $WORK_DIR/admin_center.js.1
                        cp -Rf $MWORK_DIR/mobile.js $MWORK_DIR/mobile.js.1
                        gzip -f $WORK_DIR/admin_center.js
                        gzip -f $MWORK_DIR/mobile.js
                        mv $WORK_DIR/admin_center.js.1 $WORK_DIR/admin_center.js
                        mv $MWORK_DIR/mobile.js.1 $MWORK_DIR/mobile.js
                    fi
                else
                    if [ "$MI_VER" -gt "0" ]
                    then
                        cpu_info="${dt}.cpu_vendor=\\\"${cpu_vendor}\\\";${dt}.cpu_family=\\\"${cpu_family}\\\";${dt}.cpu_series=\\\"${cpu_series}\\\";${dt}.cpu_cores=\\\"${cpu_cores}\\\";"
                    else
                        cpu_info="${dt}.cpu_vendor=\\\"${cpu_vendor}\\\";${dt}.cpu_family=\\\"${cpu_family} ${cpu_series}\\\";\\\"${dt}\\\".cpu_cores=\\\"${cpu_cores}\\\";"
                    fi
                    sed -i "s/${cpu_info}//g" $WORK_DIR/admin_center.js
                fi
            fi
        else
            COMMENT08_FN
        fi    
    fi
}

BLCHECK_FN () {
    bl_check=n
    if [ -d "$BKUP_DIR" ]
    then
        BK_CNT=`ls -l $BKUP_DIR/ | grep ^d | wc -l`
        if [ "$BK_CNT" -gt "0" ]
        then
            BK_CNT=`ls -l $BKUP_DIR/ | grep ^d | grep "$BL_CHK" | wc -l`
            if [ "$BK_CNT" -gt "0" ]
            then
                TIME=`ls -l $BKUP_DIR/ | grep ^d | grep "$BL_CHK" | awk '{print $9}' | head -1`
                BK_CNT=`ls -l $BKUP_DIR/ | grep ^d | grep -v "$BL_CHK" | wc -l`
                if [ "$BK_CNT" -gt "0" ]
                then
                    BLSUB_FN "$1"
                else
                    if [ "$re_check" == "n" ]
                    then
                        if [ "$1" == "run" ]
                        then
                            COMMENT03_FN
                        fi
                        COMMENT05_FN
                    else
                        STIME=`ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1`
                        BLSUB_FN "redo"
                    fi
                fi
            else
                if [ "$1" == "restore" ]
                then
                    COMMENT07_FN
                fi
                BK_CNT=`ls -l $BKUP_DIR/ | grep ^d | grep -v "$BL_CHK" | wc -l`
                if [ "$BK_CNT" -gt "0" ]
                then
                    BL_COM=`ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1 | awk -F_ '{print $2}'`
                    BL_CNT=`ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1 | awk -F_ '{print $2}' | wc -l`
                    if [ "$BL_COM" == "" ]
                    then
                        if [ "$BL_CNT" -gt "0" ]
                        then
                            BLSUB_FN "$1"
                            bl_check=y
                        else
                            COMMENT06_FN
                        fi
                    else
                        TIME=`ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1`
                        if [ "$BL_CHK" == "$BL_COM" ]
                        then
                            if [ "$1" == "run" ]
                            then
                                COMMENT03_FN
                            else
                                COMMENT05_FN
                                bl_check=n
                            fi
                        else
                            if [ "$BL_CHK" -gt "$BL_COM" ]
                            then
                                BLSUB_FN "$1"
                                bl_check=y
                            else
                                COMMENT06_FN
                            fi
                        fi
                    fi
                else
                    COMMENT06_FN
                fi
            fi
        else
            CASE_FN "$1"
        fi
    else
        CASE_FN "$1"
    fi
}

BLSUB_FN () {
    TIME=`echo "$STIME"`
    if [ "$1" == "run" ]
    then
        RERUN_FN "redo"
    else
        RERUN_FN "$1"
    fi
    COMMENT05_FN
}

CASE_FN () {
    case "$1" in
        run) COMMENT05_FN ;;
        redo) COMMENT07_FN ;;        
        restore) COMMENT07_FN ;;
        *) COMMENT06_FN ;;
    esac    
}

EXEC_FN () {
if [ -d $WORK_DIR ] && [ -d $MWORK_DIR ]
then    
    READ_YN "자동으로 실행합니다. n 선택시 대화형모드로 진행합니다. (취소하려면 q) [y/n] : "
    if [ "$Y_N" == "y" ]
    then
        mkdir -p $BKUP_DIR/$TIME

        if [ "$re_check" == "y" ]
        then
            if [ "$bl_check" == "y" ]
            then
 		        COMMENT04_FN
            else
                RECOVER_FN
            fi
        fi

        PREPARE_FN

        GATHER_FN

        PERFORM_FN

        APPLY_FN

        COMMENT09_FN

    elif [ "$Y_N" == "n" ]
    then
        READ_YN "원본백업 및 준비진행합니다. n 선택 시 원본에 직접작업합니다. (취소하려면 q) [y/n] : "
        if [ "$Y_N" == "y" ]    
        then
            mkdir -p $BKUP_DIR/$TIME

            if [ "$re_check" == "y" ]
            then
                if [ "$bl_check" == "y" ]
                then
 		            COMMENT04_FN
                else
                    RECOVER_FN
                fi
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

        READ_YN "CPU이름, 코어수 측정 후 반영합니다. n 선택 시 원복합니다. (취소하려면 q) [y/n] : "
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
                gzip $BKUP_DIR/mobile.js
                mv $BKUP_DIR/admin_center.js.gz $WORK_DIR/
                mv $BKUP_DIR/mobile.js.gz $MWORK_DIR/
                COMMENT09_FN
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

COMMENT03_FN () {
    echo -e "동일버전 실행 이력이 있습니다. 2) 다시실행 으로 진행바랍니다.\n"
    exit 0
}

COMMENT04_FN () {
    echo -e "상위버전 설치시 원복작업은 없습니다. 계속진행합니다.\n"
}

COMMENT05_FN () {
    echo -e "이전버전 설치 확인 및 조치완료 했습니다. 계속진행합니다.\n"
}

COMMENT06_FN () {
    echo -e "문제가 발생하여 종료합니다. 확인 후 다시 진행해주세요."
    exit 0    
}

COMMENT07_FN () {
    echo -e "수행이력이 없습니다. 처음실행으로 다시 진행해주세요."
    exit 0
}

COMMENT08_FN () {
    echo -e "작업대상 파일(경로)이 존재하지 않습니다. 확인 후 다시 진행해주세요."
    exit 0
}

COMMENT09_FN () {
    echo -e "작업이완료 되었습니다!! 반영에는 약 1~2분 소요되며, \n(F5로 DSM 페이지 새로고침 후 또는 로그아웃/로그인 후 정보를 확인바랍니다.)"
    exit 0
}

COMMENT10_FN () {
    echo -e "y / n / q 만 입력가능합니다. 다시진행해주세요."
    exit 0
}

# ==============================================================================
# Main Progress
# ==============================================================================
clear
WORK_DIR="/usr/syno/synoman/webman/modules/AdminCenter"
MWORK_DIR="/usr/syno/synoman/mobile/ui"
BKUP_DIR="/root/Xpenology_backup"
VER_DIR="/etc.default"

cecho c "DSM CPU 정보 변경 도구 ver. \033[0;31m"$ver"\033[00m - FOXBI 제작\n"

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
    PD_VER=`cat $VER_FIL | grep productversion | awk -F \= '{print $2}' | sed 's/\"//g'`
    BL_NUM=`cat $VER_FIL | grep buildnumber | awk -F \= '{print $2}' | sed 's/\"//g'`    
    BL_FIX=`cat $VER_FIL | grep smallfixnumber | awk -F \= '{print $2}' | sed 's/\"//g'`
    if [ "$BL_FIX" -gt "0" ]
    then
        BL_UP="Update $BL_FIX"
    else
        BL_UP=""
    fi
else
    COMMENT08_FN
fi

BL_CHK=$BL_NUM$BL_FIX
TIME=`date +%Y%m%d%H%M%S`"_"$BL_CHK
STIME="$TIME"

if [ "$MA_VER" -gt "4" ]
then
    if [ "$MA_VER" -eq "5" ]
    then
        MWORK_DIR="/usr/syno/synoman/webman/mapp"
    fi
    cecho g "사용중인 DSM버전은 \033[0;36mDSM \033[0;31m"$PD_VER"-"$BL_NUM" $BL_UP\033[0;32m 입니다. 계속진행합니다..\033[00m\n"
else
    echo "DSM 5 버전미만은 지원하지 않습니다. 진행을 종료합니다."
    exit 0
fi

if [ "$MA_VER" -ge "6" ]
then
    if [ "$BL_NUM" -ge "24922" ]
    then
        dt=h
    else
        dt=f
    fi
else
    dt=b
fi
    
read -n1 -p "1) 처음실행  2) 다시실행  3) 원상복구  - 번호 선택하세요 : " run_select 
   case "$run_select" in
   1) run_check=run 
      echo -e "\n " ;;
   2) run_check=redo 
      echo -e "\n " ;;
   3) run_check=restore 
      echo -e "\n " ;;
   *) echo -e "\n" ;;
   esac

if [ "$run_check" == "redo" ]
then
	READ_YN "다시실행을 진행하시겠습니까? 원본백업으로 복구 후 진행합니다.(취소하려면 q) [y/n] : "
    if [ "$Y_N" == "y" ]    
    then
        re_check=y
        BLCHECK_FN "$run_check"
        run_check=run
        EXEC_FN
    elif [ "$Y_N" == "n" ]
    then
        echo "다시실행을 진행하지 않습니다."    
    else
        COMMENT10_FN
    fi
elif [ "$run_check" = "restore" ]
then
	READ_YN "원본 백업파일을 이용하여 복구를 진행하시겠습니까? (취소하려면 q) [y/n] : "
    if [ "$Y_N" == "y" ]    
    then
        re_check=n
        BLCHECK_FN "$run_check"
        RECOVER_FN
    elif [ "$Y_N" == "n" ]
    then
        echo "복구를 진행하지 않습니다."   
    else
        COMMENT10_FN
    fi
elif [ "$run_check" = "run" ]
then
    re_check=n
    BLCHECK_FN "$run_check"
    EXEC_FN
else
    echo "올바른 번호선택바랍니다."
fi