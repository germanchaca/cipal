SLEEPTIME=5
ARGV0=emacs nethack
a=0
while true
do
	sleep $SLEEPTIME
	a=$((a+1))
	echo $a
done

