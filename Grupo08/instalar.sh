#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/build.sh
script=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
script_path=$(dirname "$script")

grupo="$script_path"
user=$(whoami)
config_file="$grupo/config/CIPAL.cnf" 

if [ ! -f $config_file ];
then
	touch "$config_file"
	echo "GRUPO=$grupo=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "BINDIR=$grupo/binarios=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "MAEDIR=$grupo/maestros=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "ARRIDIR=$grupo/arribados=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "OKDIR=$grupo/aceptados=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "PROCDIR=$grupo/procesados=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "INFODIR=$grupo/informes=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "LOGDIR=$grupo/bitacoras=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "NOKDIR=$grupo/rechazados=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "BCKP=$grupo/backup=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "LOGSIZE=10000=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	echo "SLEEPTIME=1000=$(whoami)=$(date +%d-%m-%Y\ %H:%M)" >> "$config_file"
	
	echo "Instalacion exitosa."
else
	echo "La instalacion ya se habia ejecutado previamente. No se realiza ninguna accion."
fi
