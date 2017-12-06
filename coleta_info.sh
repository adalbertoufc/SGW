#!/bin/bash

MODELO=`grep '^model name' /proc/cpuinfo | sort | uniq | cut -f2  -d ":"`
NUM_NUCLEOS=`grep '^processor' /proc/cpuinfo | wc -l`
MEM_TOTAL=`head -1 /proc/meminfo | egrep -o [0-9]*`
MEM_EM_GIGA=`echo "scale=2; $MEM_TOTAL / (1024*1024)" | bc`
CARGA=`cat /proc/loadavg`

if [[ "$MEM_EM_GIGA" =~ \.* ]]
then
	MEM_EM_GIGA="0$MEM_EM_GIGA GB"
fi
echo "$MODELO:$NUM_NUCLEOS:$MEM_EM_GIGA:$CARGA"
