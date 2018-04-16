#!/bin/sh -e
# based on https://gist.github.com/corny/7a07f5ac901844bd20c9
# updates the (public) IPv6 address and the (local?) IPv4 address

# cp ./dynv6.sh /usr/sbin
# chmod +x /usr/sbin/dynv6.sh
# ADD A CRONJOB (crontab -e)
# @reboot /usr/sbin/dynv6.sh <public_dns> <token> [device] >/var/log/dynv6 2>&1
# */20 * * * * /usr/sbin/dynv6.sh <public_dns> <token>  [device] >/var/log/dynv6 2>&1

hostname=$1
token=$2
device=$3
dynv6Path=$HOME/.dynv6
mkdir -p $dynv6Path
file6=$dynv6Path/addr6
file4=$dynv6Path/addr4

[ -e $file6 ] && old6=`cat $file6`
[ -e $file4 ] && old4=`cat $file4`

if [ -z "$hostname" -o -z "$token" ]; then
  echo "Usage:  $0 <your-name.dynv6.net> <your-authentication-token> [device]"
  exit 1
fi

if [ -z "$netmask" ]; then
  netmask=128
fi

if [ -n "$device" ]; then
  device="dev $device"
fi

address6=$(ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)
address4=$(ip -4 addr list scope global $device| grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

if [ -e /usr/bin/curl ]; then
  bin="curl -fsS"
elif [ -e /usr/bin/wget ]; then
  bin="wget -O-"
else
  echo "$(date): neither curl nor wget found"
  exit 1
fi

if [ -z "$address6" ]; then
  echo "$(date): no IPv6 address found"
  exit 1
fi

# address with netmask
current6=$address6/$netmask
current4=$address4

if [ "$old6" = "$current6" ]; then
  echo "$(date): IPv6 address unchanged: $current6"
else
  $bin "http://dynv6.com/api/update?hostname=$hostname&ipv6=$current6&token=$token"
  echo "$(date): New IPv6 address: $current6"
fi

if [ "$old4" = "$current4" ]; then
  echo "$(date): IPv4 address unchanged: $current4"
 else
  $bin "http://ipv4.dynv6.com/api/update?hostname=$hostname&ipv4=$current4&token=$token"
  echo "$(date): New IPv4 address: $current4"
fi

# send addresses to dynv6
#$bin "http://dynv6.com/api/update?hostname=$hostname&ipv6=$current&token=$token"
#$bin "http://ipv4.dynv6.com/api/update?hostname=$hostname&ipv4=auto&token=$token"

# save current address
echo $current6 > $file6
echo $current4 > $file4
