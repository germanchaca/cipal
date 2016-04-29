#!/bin/bash

#TODO Revisar ambiente
	#TODO Checkear archivos y directorios existentes
	#TODO Checkear permisos en archivos

#TODO Si es necesario reparar ambiente.
	#TODO Crear directorio de recovery con los ejecutables para restaurarlos	

config_file="../config/CIPAL.cnf"
IFS='='
	while read var value user record_date
	do
		echo "variable: $var"
		echo "valor: $value"
		echo "usuario: $user"
		echo "fecha: $record_date"
	done < $config_file
	
	#TODO Setear variables de entorno

#TODO preguntar por ejecucion de RecibirOfertas

