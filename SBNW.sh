#!/bin/bash

# Hack-exercise
# Creiamo un piccolo "demone" (es. uno script bash) che:
# 0 - Monitora il MAC Address
# 1 - Avverte l'utente che il MAC è cambiato
# 10 - Chiude tutte le connessioni relative alla NIC "esposta"
# sono ben accetti "effetti speciali" usati come alarm per avvertire l'utente che il MAC spoofing è fallito in quanto la NIC è stata ripristinata con il vero MAC Address

clear
echo "welcome..."
sleep 3
clear

echo "Subliminal Message: Hack The Planet! :-P"
sleep  1
clear

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

publicIP=$(curl -s https://4.ifcfg.me/)
privateIP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

echo I\'m checking if:
echo -e "\t\tPublic IP: $publicIP"
echo -e "\t\tPrivate IP: $privateIP"
echo -e "\t\tMAC Address is still ${MACs[$device]} on ${devices[$device]}..."

while(true);
 #Simuliamo il: watch -n 1 -d "ip addr show ${myarray[$device]} | grep -m 1 '${myarray[$macaddress]}'"
do
 CURRENTMAC=$(ifconfig ${myarray[$device]} | awk 'match($0,/(..:..:..:..:..:..)/) {print substr($0,RSTART,RLENGTH)}');
 if [[ *$CURRENTMAC* != *${myarray[$macaddress]}* ]];
 then
  echo "  ___ ______________.____   __________ "
  echo " /   |   \_   _____/|    |  \______   \\"
  echo "/    ~    \    __)_ |    |   |     ___/"
  echo "\    Y    /        \|    |___|    |    "
  echo " \___|_  /_______  /|_______ \____|    "
  echo "       \/        \/         \/         "

  echo "God Save the Queen! :: MAC Address Changed!"

  ( speaker-test -t sine -f 1000 > /dev/null )& pid=$! ; sleep 1s ; kill -9 $pid
  break;
 fi
done;


if [ $? -eq 0 ]
then
  echo "Successfully watched"
else
  echo "Something happened" >&2
fi

exit 0 #  By convention, an 'exit 0' indicates success

# (1)
#Scusate per la pessima regex che ho elaborato, ma ciò che trovavo in rete non mi piaceva: 
#((.+: )|(..:..:..:..:..:..))
#1) ifconfig -a | grep ether | awk '{print $2}'
#2) ip -o link show | awk -F': ' '{print "\n" $2 ": " $3 "\n"}'
#3) solo il nome del dispositivo esclusi spazi e interfaccia lo(localhost/loopback): ifconfig -a | sed 's/[ \t].*//;/^\(lo:\|\)$/d'
#4) ip -o link show | awk -F': ' '{print $2}'
#5) ifconfig -a | grep -E '((.+: )|(..:..:..:..:..:..))'
#6) ifconfig -a | awk 'match($0,/((.+: )|(..:..:..:..:..:..))/) {print substr($0,RSTART,RLENGTH)}'
