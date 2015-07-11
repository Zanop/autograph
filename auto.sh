#!/bin/bash

HOSTS=("87.248.223.151 ic.4d461a73.0a3637.40.c3495.d.rncdn3.com /video2/d/d8/ce82bf33098c2df04ecd0eafd3888fd8.mp4" "185.18.187.2 185.18.187.2 :84/t.mp4")
RANGE="0-10000000"
SAMPLES="3"
IFACE="en0"
GFORMAT="png"  # select png or pdf here


test -d graphs || mkdir graphs
test -d tmp || mkdir tmp
test -d dumps || mkdir dumps

for i in {0..1}; do
	host=`echo ${HOSTS[$i]}| awk '{print $1}'`
	vhost=`echo ${HOSTS[$i]}| awk '{print $2}'`
	uri=`echo ${HOSTS[$i]}| awk '{print $3}'`
	for s in `seq 1 $SAMPLES`; do
		sudo tcpdump -n -i $IFACE -w dumps/${host}-${s}.pcap host $host &
		TCPDUMP_PID=$!
		curl -o /dev/null -r $RANGE --header "Host: $vhost" http://${host}${uri}
		# wait for possible packets in flight before we kill tcpdump
		sleep 2
		kill $TCPDUMP_PID
		# wait for tcpdump to quit
		wait $TCPDUMP_PID
		echo $?
		captcp throughput -p -s 0.05 -i -o tmp dumps/${host}-${s}.pcap
		captcp timesequence -e -f 1.1 -i -o tmp dumps/${host}-${s}.pcap
		captcp spacing -a 50 -f 1.1 -i -o tmp dumps/${host}-${s}.pcap
		cd tmp
		make png
		mv time-sequence.${GFORMAT} ../graphs/ts-${host}-${s}.${GFORMAT}
		mv throughput.${GFORMAT} ../graphs/${host}-${s}.${GFORMAT}
		mv spacing.${GFORMAT} ../graphs/spacing-${host}-${s}.${GFORMAT}
		cd -
	done
done

# Montage all into one image
montage -label '%f' -tile 3x -geometry 700x500 -pointsize 18 -frame 5 -alpha remove graphs/*.png mon.png
