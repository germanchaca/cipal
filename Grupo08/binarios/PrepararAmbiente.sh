#!/bin/bash

#Parametros:
#		1.mensaje a guardar en bitacora
#		2.tipo de mensaje (INFO, WAR, ERR)
function grabarBitacora() {
	local command="PrepararAmbiente"
  	local msj=$1
	local msj_type=$2
	local grab_bitac="./GrabarBitacora.pl"
 	chkFileExists "$grab_bitac"
  	"$grab_bitac" "$command" "$msj" "$msj_type"
}

function chkFileExists(){
	if [ ! -f "$1" ];
	then
		return 1
	fi
}

function chkDirExists(){
	if [ ! -d "$1" ];
	then
		return 1
	fi
}

function showErrorFileNotFound(){
	error="Error: No existe el archivo $PWD/$1"
	echo $error
	grabarBitacora $error "ERR"
}

function showErrorDirNotFound(){
	error="Error: No existe el directorio $PWD/$1"
	echo $error
	grabarBitacora $error "ERR"
}



#TODO Revisar ambiente
	#TODO Checkear archivos y directorios existentes

config_dir="../config"
config_file="$config_dir/CIPAL.cnf"

if [ ! -d $config_dir ];
then
	showErrorDirNotFound $config_dir
	return 1
fi

if [ ! -f $config_file ];
then
	showErrorFileNotFound $config_file
	return 1
fi


	
	#TODO Checkear permisos en archivos

#TODO Si es necesario reparar ambiente.
	#TODO Crear directorio de recovery con los ejecutables para restaurarlos	

IFS='='
	while read var value user record_date
	do
		export "$var"="$value"
		echo "Variable $var inicializada con valor $value"
		grabarBitacora "Variable ${var} inicializada con valor ${value}" "INFO"
	done < $config_file

	echo "Estado del Sistema: INICIALIZADO"
	grabarBitacora "Estado del Sistema: INICIALIZADO" "INFO"

	read -p "¿Desea efectuar la activación de RecibirOfertas? Si – No: " reply
	
	while [[ ! $reply =~ ^[sS][iI]?$ ]] && [[ ! $reply =~ ^[nN][oO]?$ ]]
	do
		echo "Respuesta invalida."
		read -p "¿Desea efectuar la activación de RecibirOfertas? Si – No: " reply
	done

	if [[ $reply =~ ^[sS][iI]?$ ]];
	then
		echo "Lanzando RecibirOfertas"
		$(./LanzarProceso.sh -b RecibirOfertas.sh)
		echo "Para detener el proceso RecibirOfertas, se debe invocar el comando \"./DetenerProceso.sh RecibirOfertas.sh\""
	else
		echo "Para lanzar el proceso RecibirOfertas, se debe invocar el comando \"./LanzarProceso.sh -b RecibirOfertas.sh"
	fi 
