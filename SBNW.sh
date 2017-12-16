#!/bin/bash

# Hack-exercise
# Creiamo un piccolo "demone" (es. uno script bash) che:
# 0 - Monitora il MAC Address
# 1 - Avverte l'utente che il MAC è cambiato
# 10 - Chiude tutte le connessioni relative alla NIC "esposta"
# sono ben accetti "effetti speciali" usati come alarm per avvertire l'utente che il MAC spoofing è fallito in quanto la NIC è stata ripristinata con il vero MAC Address

function status(){
    #echo -e "\nMachine information:" ; uname -a
    #gnome-terminal -e "bash -c \"echo -e '\nMachine information:'; uname -a; exec bash\""

    #echo -e "\nUsers logged on:" ; w -h
    #gnome-terminal -e "bash -c \"(resize -s 10 100 > /dev/null); watch -t -d -n 1 \"echo -e '\tUsers:' && w && echo -e '\n\tSpace:' && free

	echo "echo $'\e[32;4m\tUsers:\e[0m' && w" > /tmp/w.tmp
	chmod +x /tmp/w.tmp
	gnome-terminal -e "bash -c \"(resize -s 10 100 > /dev/null); watch  -d -n 1 \"/tmp/w.tmp\"; exec bash\"" 2> /dev/null
	#rm /tmp/status.tmp ***

    #echo -e "\nCurrent date :" ; date

    #echo -e "\nMachine status :" ; uptime

    #echo -e "\nMemory status :" ; free

    #echo -e "\nFilesystem status :"; df -h

	echo "echo $'\e[32;4m\tMemory:\e[0m' && free && echo $'\e[32;4m\n\tSpace:\e[0m' && df" > /tmp/free-df.tmp
	chmod +x /tmp/free-df.tmp
	gnome-terminal -e "bash -c \"(resize -s 10 100 > /dev/null); watch  -d -n 1 \"/tmp/free-df.tmp\"; exec bash\"" 2> /dev/null
}


function warning(){
  echo "  ___ ______________.____   __________ "
  echo " /   |   \_   _____/|    |  \______   \\"
  echo "/    ~    \    __)_ |    |   |     ___/"
  echo "\    Y    /        \|    |___|    |    "
  echo " \___|_  /_______  /|_______ \____|    "
  echo "       \/        \/         \/         "

  echo "God Save the Queen! :: ${1}"

  ( speaker-test -t sine -f 1000 > /dev/null )& pid=$! ; sleep 1s ; kill -9 $pid
}

function StaccaStaccaStacca(){
 if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo to allow disable interface:"
    echo "sudo $0 $*"
    exit 1
 fi

 sudo ifconfig ${devices[$device]} down
}

function WelcomeMsg(){
 clear
 echo "welcome..."
 sleep 3
 clear

 for((i=0; i<20; i++));
  do
   LINES=$((${i}*2));
   COLUMNS=$(((${i}+8)*2));
   resize -s ${LINES} ${COLUMNS} > /dev/null
   sleep 1
  done

  echo "Subliminal Message: Hack The Planet! :-P"
  sleep  1
  clear
 }


function dafare(){
 ps -A | grep 3368 | awk '{print $4}' # gli dai il PID e ti dice il processo
}

#gnome-terminal -e "bash -c \"ls; exec bash\""
WelcomeMsg

echo "MAC Addresses here are:"
DEVICES=$(ifconfig -a | awk 'match($0,/((.+: ))/) {print substr($0,RSTART,RLENGTH)}')
DEVICES=$(echo $DEVICES | tr -d "\n\r:")
split=',' read -a devices <<< "$DEVICES"

printf "\n"
Ndevices=${#devices[@]}
for((i=0; i<${Ndevices}; i++));
 do
  printf "%d) \t %s\t->\t" $i ${devices[$i]}
  MACs[$i]=$(ifconfig ${devices[$i]} | awk 'match($0,/(..:..:..:..:..:..)/) {print substr($0,RSTART,RLENGTH)}')
  printf "%s\n" ${MACs[$i]}
 done


echo "Insert NUMBER of your device/MAC Address to watch: "
read device

#if [${device} -lt 0] || [$device > ${Ndevices}]
# then
#  echo Error: insert valid number.
#  exit -1
#fi

echo "I'm watching ${devices[$device]} of ${MACs[$device]}"
sleep 3
clear
echo "Press CTRL + C to exit"
echo -e "\n"
sleep 3


# start standard config
delaysec=5
# end standard config


publicIP=$(curl -s https://4.ifcfg.me/)
privateIP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

status


echo -e "\nI\'m checking each ${delaysec} second(s) if:"
echo -e "\t\tPublic IP: $publicIP"
echo -e "\t\tPrivate IP: $privateIP"
echo -e "\t\tMAC Address is still ${MACs[$device]} on ${devices[$device]}..."

while(true);
do
 #Simuliamo il: watch -n 1 -d "ip addr show ${myarray[$device]} | grep -m 1 '${myarray[$macaddress]}'"
 CURRENTMAC=$(ifconfig ${devices[$device]} | awk 'match($0,/(..:..:..:..:..:..)/) {print substr($0,RSTART,RLENGTH)}');
 if [[ *$CURRENTMAC* != *${MACs[$device]}* ]];
 then
  warning "Mac Address Changed!"
  StaccaStaccaStacca
  break;
 fi

 #*** potrebbe non funzionare in presenza di due IP privati
 CURRENTPRIVATEIP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
 if [[ *$CURRENTPRIVATEIP* != *$privateIP* ]];
 then
  warning "Private IP Changed!"
  StaccaStaccaStacca
  break;
 fi

 sleep ${delaysec}
done;


if [ $? -eq 0 ]
then
  echo "Successfully watched"
else
  echo "Something happened" >&2
fi

exit 0 #  By convention, an 'exit 0' indicates success
