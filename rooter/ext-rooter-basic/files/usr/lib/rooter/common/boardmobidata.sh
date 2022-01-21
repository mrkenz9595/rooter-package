#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "Boardmobi Data" "$@"
}

CURRMODEM=$1
COMMPORT=$2

OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "boardmobiinfo.gcom" "$CURRMODEM" | tr 'a-z' 'A-Z')

O=$($ROOTER/common/processat.sh "$OX")
O=$(echo $O)
OX=$(echo $OX)

RSRP=""
RSRQ=""
CHANNEL="-"
ECIO="-"
RSCP="-"
ECIO1=" "
RSCP1=" "
MODE="-"
MODTYPE="-"
NETMODE="-"
LBAND="-"
TEMP="-"
PCI="-"
SINR="-"

CSQ=$(echo $OX | grep -o "+CSQ: [0-9]\{1,2\}" | grep -o "[0-9]\{1,2\}")
if [ "$CSQ" = "99" ]; then
	CSQ=""
fi
if [ -n "$CSQ" ]; then
	CSQ_PER=$(($CSQ * 100/31))"%"
	CSQ_RSSI=$((2 * CSQ - 113))" dBm"
else
	CSQ="-"
	CSQ_PER="-"
	CSQ_RSSI="-"
fi

MODE="-"
BMRAT=$(echo $O" " | grep -o "+BMRAT: .\+ OK " | tr " " ",")
TECH=$(echo $BMRAT | cut -d, -f2)
if [ -n "$TECH" ]; then
	MODE=$TECH
fi

SGCELL=$(echo $O" " | grep -o "+BMTCELLINFO: .\+ OK " | tr " " ",")

case $MODE in
	"TD-LTE"|"FDD-LTE"|"FDD")
		RSSI=$(echo $SGCELL | cut -d, -f4)
		CSQ_RSSI="-"$(echo $RSSI | grep -o "[0-9]\{1,3\}")" dBm"
		RSCP=$(echo $SGCELL | cut -d, -f6)
		RSCP="-"$(echo $RSCP | grep -o "[0-9]\{1,3\}")
		ECIO=$(echo $SGCELL| cut -d, -f8)
		ECIO="-"$(echo $ECIO | grep -o "[0-9]\{1,3\}")
		SINR=$(echo $SGCELL | cut -d, -f10 | grep -o "[0-9]\{1,3\}")
		if [ -n "$SSINR" -a "$SSINR" -le "250" ]; then
			SINR=$((($SINR / 5) - 20))" dB"
		fi
		LBAND=$(echo $SGCELL | cut -d, -f12)
		LBAND=$(echo $LBAND | grep -o "[0-9]\{1,5\}")
		let LBAND=LBAND
		LBAND="B"$LBAND
		CHANNEL=$(echo $SGCELL | cut -d, -f14)
		CHANNEL=$(echo $CHANNEL | grep -o "[0-9]\{1,5\}")
		ICELL=$(echo $O" " | grep -o "+CELLINFO: .\+ OK " | tr " " ",")
		PCI=$(echo $ICELL | cut -d, -f16)
		PCI=$(echo $PCI | grep -o "[0-9]\{1,5\}")
		if [ $MODE = "FDD" ]; then
			MODE="LTE"
		fi
		;;
	"HSPA+"|"HSUPA"|"HSDPA"|"WCDMA")
		RSCP=$(echo $SGCELL | cut -d, -f11)
		RSCP="-"$(echo $RSCP | grep -o "[0-9]\{1,3\}")
		ECIO=$(echo $SGCELL| cut -d, -f12)
		ECIO="-"$(echo $ECIO | grep -o "[0-9]\{1,3\}")
		CHANNEL=$(echo $SGCELL | cut -d, -f8)
		CHANNEL=$(echo $CHANNEL | grep -o "[0-9]\{1,4\}")
		RSSI=$(echo $SGCELL | cut -d, -f10)
		CSQ_RSSI=$(echo $RSSI | grep -o "[0-9]\{1,3\}")" dBm"
		;;
	*)
		RSCP=$(echo $SGCELL | cut -d, -f10)
		RSCP="-"$(echo $RSCP | grep -o "[0-9]\{1,3\}")
		CHANNEL=$(echo $SGCELL | cut -d, -f8)
		CHANNEL=$(echo $CHANNEL | grep -o "[0-9]\{1,4\}")
		RSSI=$(echo $SGCELL | cut -d, -f9)
		CSQ_RSSI=$(echo $RSSI | grep -o "[0-9]\{1,3\}")" dBm"
		;;
esac

NETMODE="-"
NMODE=$(echo $O" " | grep -o "+BMMODODR: .\+ OK " | tr " " ",")
TECH=$(echo $NMODE | cut -d, -f2)
if [ -n "$TECH" ]; then
	MODTYPE="7"
	case $TECH in
	"11"|"2" )
		NETMODE="1" # Auto
		;;
	"1"|"8" )
		NETMODE="5" # 3G only
		;;
	"7" )
		NETMODE="4" # 3G preferred
		;;
	"3" )
		NETMODE="3" # 2G only
		;;
	"5" )
		NETMODE="7" # LTE only
		;;
	* )
		NETMODE="1"
		;;
	esac
fi

{
	echo 'CSQ="'"$CSQ"'"'
	echo 'CSQ_PER="'"$CSQ_PER"'"'
	echo 'CSQ_RSSI="'"$CSQ_RSSI"'"'
	echo 'ECIO="'"$ECIO"'"'
	echo 'RSCP="'"$RSCP"'"'
	echo 'ECIO1="'"$ECIO1"'"'
	echo 'RSCP1="'"$RSCP1"'"'
	echo 'MODE="'"$MODE"'"'
	echo 'MODTYPE="'"$MODTYPE"'"'
	echo 'NETMODE="'"$NETMODE"'"'
	echo 'CHANNEL="'"$CHANNEL"'"'
	echo 'LBAND="'"$LBAND"'"'
	echo 'TEMP="'"$TEMP"'"'
	echo 'PCI="'"$PCI"'"'
	echo 'SINR="'"$SINR"'"'
}  > /tmp/signal$CURRMODEM.file

CONNECT=$(uci get modem.modem$CURRMODEM.connected)
if [ "$CONNECT" == "0" ]; then
    exit 0
fi

if [ "$CSQ" = "-" ]; then
	log "$OX"
fi

WWANX=$(uci get modem.modem$CURRMODEM.interface)
OPER=$(cat /sys/class/net/$WWANX/operstate 2>/dev/null)

if [ ! "$OPER" ]; then
	exit 0
fi
if echo $OPER | grep -q "unknown"; then
	exit 0
fi

if echo $OPER | grep -q "down"; then
	echo "1" > "/tmp/connstat"$CURRMODEM
fi

