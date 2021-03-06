#!/system/bin/sh
### Make sure to stop the server before modifying the parameters

# Main listen port
Listen_PORT='6453'
# Route listen port
Route_PORT=''

# Server permission [radio/root] (Some operations may want to use root)
ServerUID='radio'

# iptables block IPv6 port 53 [true/false]
IP6T_block=true

# Limit queries from non-LAN
Strict=true


####################
### Don't modify it.
####################
# PATHs
#########
IPT="/system/bin/iptables"
IP6T="/system/bin/ip6tables"

ROOT="/dev/smartdns_root"

CORE_INTERNAL_DIR="$MODDIR/binary"
DATA_INTERNAL_DIR="/data/media/0/Android/smartdns"

CORE_DIR="$ROOT/binary"
DATA_DIR="$ROOT/config"
LOCAL_DIR="/data/local/tmp/smartdns"

CORE_BINARY="smartdns-server"
CORE_BOOT="$CORE_DIR/$CORE_BINARY -c $DATA_DIR/smartdns.conf -p $ROOT/core.pid"

################
# Tool functions
################

save_value() {
	local tmp=$(grep "^$1=" $MODDIR/lib.sh)
	value_change=true
	if [ -z "${3}" ]; then
		sed -i "s#^$tmp#$1=\'$2\'#g" $MODDIR/lib.sh
	else
		sed -i "s#^$tmp#$1=$2#g" $MODDIR/lib.sh
	fi
	return $?
}

server_check() {
	local i=0
	service_check || i=`expr $i + 2`
	iptrules_check || ((++i))

	case ${i} in
		3)  # Not working
			return 3 ;;
		2)  # Server not working
			return 2 ;;
		1)  # iptrules not load
			return 1 ;;
		0)  # Working
			return 0 ;;
	esac
}
