#!/bin/bash

## EnvVar
warn_day=30
date_now=$(date +%F)
spr="+--------------------------------+------+-------------+-----------+------------------------------+----------+-----------------+----------------+"

usage()
{
	echo -e "For help         : ./chk-ssl.sh [-h help]"
	echo -e "Read from file   : ./chk-ssl.sh [-f file]"
	echo -e "Single hostname  : ./chk-ssl.sh [-n hostname] [-p port]"	
}

header()
{
	printf "+----------------------------------------------------------------------------------------------------------------------------------------------+\n"
	printf "| %-150s |\n" "$(tput bold)SSL Expiry Checker$(tput sgr0)"
	printf "| %-150s |\n" "$(tput bold)Threshold: ${warn_day} days$(tput sgr0)"
	printf "| %-150s |\n" "$(tput bold)Author: Rija Rizki$(tput sgr0)"
	printf "${spr}\n"
	printf "| %-40s | %-4s | %-11s | %-9s | %-38s | %-8s | %-25s | %-24s |\n" "$(tput bold)Host$(tput sgr0)" "$(tput bold)Port$(tput sgr0)" "$(tput bold)Date Expiry$(tput sgr0)" "$(tput bold)Days Left$(tput sgr0)" "$(tput bold)Issuer$(tput sgr0)" "$(tput bold)Wildcard$(tput sgr0)" "$(tput bold)IP$(tput sgr0)" "$(tput bold)Status$(tput sgr0)"	
}

chkProcess()
{
	date_exp=$(echo | openssl s_client -servername ${host} -connect ${host}:${port} 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d'=' -f2 | awk '{if ($2 < 10) print "0"$2,$1,$4; else print $2,$1,$4}')
	if [[ -n ${date_exp} ]]; then
		count_day=$(echo $((($(date -d "${date_exp}" +%s) - $(date -d ${date_now} +%s)) / 86400)))
		issuer=$(echo | openssl s_client -servername ${host} -connect ${host}:${port} 2>/dev/null | openssl x509 -noout -issuer 2>/dev/null | awk -F'O = ' '{print $2}' | cut -d'=' -f1 | sed -e 's/[.,"]//g' -e 's/CN//' -e 's/OU//')
		chk_wildcard=$(echo | openssl s_client -servername ${host} -connect ${host}:${port} 2>/dev/null | openssl x509 -noout -text | grep DNS | awk '{print $1}' | cut -d":" -f2 | cut -d '.' -f1)
		if [[ ${count_day} -gt ${warn_day} ]]; then
			status=$(echo $(tput setaf 2)OK$(tput sgr0))
		elif [[ ${count_day} -lt 0 ]]; then
			status=$(echo $(tput setaf 1)Expired$(tput sgr0))
			count_day="-"
		else
			status=$(echo $(tput setaf 3)Please update$(tput sgr0))
		fi
		if [[ ${chk_wildcard} == "*" ]]; then
			wildcard="Yes"
		else
			wildcard="No"
		fi
		ip=$(dig ${host} | grep "ANSWER SECTION" -A5 | grep -vP 'CNAME|ANSWER' | awk NR==1'{print $5}')
	else
		date_exp="-"
		count_day="-"
		status=$(echo $(tput setaf 1)Not available$(tput sgr0))
		issuer="-"
		wildcard="-"
		ip="-"
	fi
	printf "| %-40s | %4s | %11s | %9s | %-28s | %-8s | %-15s | %-25s |\n" "$(tput bold)${host}$(tput sgr0)" "${port}" "${date_exp}" "${count_day}" "${issuer}" "${wildcard}" "${ip}" "${status}"
}

readFile()
{
	printf "${spr}\n"
	while read -r line || [[ -n "$line" ]]
	do
		[[ $line =~ ^#|^$ ]] && continue
		host=$(echo ${line} | awk '{print $1}')
		port=$(echo ${line} | awk '{print $2}')
		chkProcess
	done < "$1" 
	printf "${spr}\n"
}

singleHost()
{
	printf "${spr}\n"
	chkProcess
	printf "${spr}\n"
}

# Parse command line options
while getopts "hf:n:p:" opt; do
    case ${opt} in
        h)
            usage
            exit 0
            ;;
        f)
            file=$OPTARG
            ;;
        n)
            hostname=$OPTARG
            ;;
        p)
            port=$OPTARG
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

# Ensure at least one option is provided
if [ -z "$file" ] && [ -z "$hostname" ]; then
    usage
    exit 1
elif [ -n "$file" ]; then
    if [ -f "$file" ]; then
		header
        readFile "$file"
    else
        echo "File not found: $file"
        exit 1
    fi
elif [ -n "$hostname" ] && [ -n "$port" ]; then
    host="$hostname"
	header
    singleHost
else
    usage
    exit 1
fi
