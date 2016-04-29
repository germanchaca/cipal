#!/bin/bash

#TODO Revisar ambiente
	#TODO Checkear archivos y directorios existentes
	#TODO Checkear permisos en archivos

#TODO Si es necesario reparar ambiente.
	#TODO Crear directorio de recovery con los ejecutables para restaurarlos	


GRABAR='perl GrabarBitacora.pl PrepararAmbiente'
config_file="../config/CIPAL.cnf"
IFS='='
	while read var value user record_date
	do
		export "$var"="$value"
		echo "Variable $var inicializada con valor $value"
		$GRABAR "Variable $var inicializada con valor $value"
	done < $config_file

	echo "Estado del Sistema: INICIALIZADO"
	$GRABAR "Estado del Sistema: INICIALIZADO"

	read -p "¿Desea efectuar la activación de RecibirOfertas? Si – No: " reply
	
	while [[ ! $reply =~ ^[sS][iI]?$ ]] && [[ ! $reply =~ ^[nN][oO]?$ ]]
	do
		echo "Respuesta invalida."
		read -p "¿Desea efectuar la activación de RecibirOfertas? Si – No: " reply
	done

	if [[ $reply =~ ^[sS][iI]?$ ]];
	then
		echo "Lanzando RecibirOfertas"
		$(./LanzarProceso.sh RecibirOfertas.sh)
		echo "Para detener el proceso RecibirOfertas, se debe invocar el comando \"./DetenerProceso.sh RecibirOfertas.sh\""
	else
		echo "Para lanzar el proceso RecibirOfertas, se debe invocar el comando \"./LanzarProceso.sh RecibirOfertas.sh"
	fi 
