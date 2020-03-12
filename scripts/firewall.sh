#!/bin/bash
#
openshift_ports="53/UDP 443/TCP 1936/TCP 4001/TCP 7001/TCP 8053/UDP 8443/TCP 10250_10259/TCP"
#
[[ -z $* || $(echo $* | xargs -n1 | wc -l) -ne 2 || ! ($* =~ $(echo '\<open\>') || $* =~ $(echo '\<close\>')) ]] && { echo "Please pass in the desired action [ open, close ] and instance [ site_myweb ]." && exit 2; }
#
instance="$(echo $* | xargs -n1 | sed '/\<open\>/d; /\<close\>/d')"
[[ -z $instance ]] && { echo "Please double-check the passed in instance." && exit 1; }
action="$(echo $* | xargs -n1 | grep -v $instance)"
#
for port in $openshift_ports; do
        aws lightsail $action-instance-public-ports --instance $instance --port-info fromPort=$(echo $port | cut -f1 -d_ | cut -f1  -d/),protocol=$(echo $port | cut -f2 -d/),toPort=$(echo $port | cut -f2 -d_ | cut -f1 -d/)
done
#

exit 0
