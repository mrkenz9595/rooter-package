#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Status Update" "$@"
}

levelsper="101,85,70,55,40,25,10,0"
namesper="Perfect,Excellent,Good,Medium,Low,Bad,Dead"
levelsrssi="113,119,100,90,70,0"
namesrssi="None,Bad,Poor,Medium,High"
levelsrscp="140,136,112,100,90,70,50,0"
namesrscp="None,None (3G) : Poor (4G),Weak (3G) : Medium (4G),Poor (3G) : Good (4G),Medium (3G) : High (4G),High (3G) :High (4G)"

level2txt() {
	tmp="$1"
	key=$2
	front=""
	tmp1="$tmp"" "
	if [ "$tmp" = "-" ]; then
		namev="<b class='level_2'>""--""</b>"
		return
	fi
	if [ $key = "per" ]; then
		tmp=$(echo "$tmp" | sed -e "s/%//g")
		level=$levelsper
		name=$namesper
	fi
	if [ $key = "rssi" ]; then
		front="-"
		tmp=$(echo "$tmp" | sed -e "s/-//g")
		tmp=$(echo "$tmp" | sed -e "s/dBm//g")
		tmp1="$tmp"" "
		level=$levelsrssi
		name=$namesrssi
	fi
	if [ $key = "rscp" ]; then
		front="-"
		tmp=$(echo "$tmp" | sed -e "s/-//g")
		tmp=$(echo "$tmp" | sed -e "s/dBm//g")
		tmp1="$tmp"" "
		level=$levelsrscp
		name=$namesrscp
	fi
	
	if [ $key = "single" ]; then
		desc=""
		tmp=$(echo "$tmp" | sed -e "s/-//g")
		tmp=$(echo "$tmp" | sed -e "s/dBm//g")
		tmp=$(echo "$tmp" | sed -e "s/dB//g")
		if [ $3 = "1" ];then
			tmp="-"$tmp
		fi
		if [ $3 = "1" -o $3 = "0" ];then
			desc="<br><i class='msDesc'>"."</i></br>"
		fi
		namev="<b class='level_2'>""$tmp""</b>"$desc
		return
	fi
	
	cindex=1
	nindex=0
	namev="-"
	while [ true ]
	do
		levelv=$(echo "$level" | cut -d, -f$cindex)
		if [ $levelv = "0" ]; then
			namev="-"
			break
		fi
		if [ "$tmp" -ge "$levelv" ]; then
			namev=$(echo "$name" | cut -d, -f$nindex)
			break
		fi
		cindex=$((${cindex}+1))
		nindex=$((${nindex}+1))
	done

	css="level_"$nindex
	desc="<br><i class='msDesc'>"$namev"</i></br>"
	namev="<b class='"$css"'>""$front$tmp1""</b>"$desc
}

readstatus() {
	while IFS= read -r line; do
		port="$line"
		read -r line
		csq="$line"
		read -r line
		per="$line"
		read -r line
		rssi="$line"
		read -r line
		modem="$line"
		read -r line
		cops="$line"
		read -r line
		mode="$line"
		read -r line
		lac="$line"
		read -r line
		lacn="$line"
		read -r line
		cid="$line"

		read -r line
		cidn="$line"
		read -r line
		mcc="$line"
		read -r line
		mnc="$line"
		read -r line
		rnc="$line"
		read -r line
		rncn="$line"
		read -r line
		down="$line"
		read -r line
		up="$line"
		read -r line
		ecio="$line"
		read -r line
		rscp="$line"
		read -r line
		ecio1="$line"

		read -r line
		rscp1="$line"
		read -r line
		netmode="$line"
		read -r line
		cell="$line"
		read -r line
		modtype="$line"
		read -r line
		conntype="$line"
		read -r line
		channel="$line"
		read -r line
		phone="$line"
		read -r line
		read -r line
		lband="$line"
		read -r line
		tempur="$line"

		read -r line
		proto="$line"
		read -r line
		pci="$line"
		read -r line
		sinr="$line"
		break
	done < /tmp/status1.file
}

bwdata() {
	while IFS= read -r line; do
		if [ $line = '0' ]; then
			nodata="1"
			break
		else
			nodata="0"
			days=$line
			read -r line
			read -r line
			tused=$line
			read -r line
			read -r line
			tdwn=$line
			read -r line
			read -r line
			tup=$line
			read -r line
			read -r line
			project=$line
			break
		fi
	done < /tmp/bwdata
}

splash=$(uci -q get iframe.iframe.splashpage)

if [ $splash = "1" ]; then
	STEMP="/tmp/www/stemp.html"
	STATUS="/usr/lib/iframe/status.html"
	SPSTATUS="/tmp/www/splash.html"
	rm -f $STEMP
	cp $STATUS $STEMP
	button="<div class='rooterPageContentBut'><div class="" id=\"rooterItems\"><a href='cgi-bin/luci'><div class=\"rooterItem\" id=\"rooterItem1\"><div class=\"rooterItemTitle\"><i class='icon icon-cog'></i> Click for Router Login</div><div class=\"rooterItemTitle\">to the Web GUI.</div></div></a></div></div>"
	sed -i -e "s!#BUTTON#!$button!g" $STEMP
	sed -i -e "s!#LUCIS#!luci-static/!g" $STEMP
	titlebar="<div class='rooterPageHead'><a  href='http://www.ofmodemsandmen.com'><div class=\"rooterHeadTitle\"> #TITLE#</div></a></div>"
	sed -i -e "s!#TITLEBAR#!$titlebar!g" $STEMP
	title=$(uci -q get iframe.iframe.splashtitle)
	sed -i -e "s!#TITLE#!$title!g" $STEMP

	readstatus
	level2txt "$csq" "single" 0
	sed -i -e "s!#CSQ#!$namev!g" $STEMP
	level2txt "$per" "per"
	sed -i -e "s!#PER#!$namev!g" $STEMP
	level2txt "$rssi" "rssi"
	sed -i -e "s!#RSSI#!$namev!g" $STEMP
	level2txt "$rscp" "rscp"
	sed -i -e "s!#RSCP#!$namev!g" $STEMP
	level2txt "$ecio" "single" 1
	sed -i -e "s!#RSRQ#!$namev!g" $STEMP
	level2txt "$sinr" "single" 1
	sed -i -e "s!#SINR#!$namev!g" $STEMP

	level2txt "$mode" "single"
	sed -i -e "s!#MODE#!$namev!g" $STEMP
	level2txt "$mcc" "single"
	sed -i -e "s!#MCC#!$namev!g" $STEMP
	level2txt "$mnc" "single"
	sed -i -e "s!#MNC#!$namev!g" $STEMP
	level2txt "$rnc" "single"
	sed -i -e "s!#RNC#!$namev!g" $STEMP
	level2txt "$rncn" "single"
	sed -i -e "s!#RNCN#!$namev!g" $STEMP
	level2txt "$lac" "single"
	sed -i -e "s!#LAC#!$namev!g" $STEMP
	level2txt "$lacn" "single"
	sed -i -e "s!#LACN#!$namev!g" $STEMP
	level2txt "$pci" "single"
	sed -i -e "s!#CELLID#!$namev!g" $STEMP
	level2txt "$channel" "single"
	sed -i -e "s!#CHAN#!$namev!g" $STEMP
	level2txt "$lband" "single"
	sed -i -e "s!#BAND#!$namev!g" $STEMP

	level2txt "$modem" "single"
	sed -i -e "s!#MODEM#!$namev!g" $STEMP
	level2txt "$proto" "single"
	sed -i -e "s!#PROTO#!$namev!g" $STEMP
	level2txt "$port" "single"
	sed -i -e "s!#PORT#!$namev!g" $STEMP
	level2txt "$tempur" "single"
	sed -i -e "s!#TEMP#!$namev!g" $STEMP

	mv $STEMP $SPSTATUS
fi


