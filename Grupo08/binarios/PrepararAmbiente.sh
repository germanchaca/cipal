#!/bin/bash

#TODO Revisar ambiente
	#TODO Checkear archivos y directorios existentes
	#TODO Checkear permisos en archivos

#TODO Si es necesario reparar ambiente.
	#TODO Crear directorio de recovery con los ejecutables para restaurarlos	

IFS='
'
for linea in `cat ../config/CIPAL.cnf`; do
	echo "$linea"
	#TODO Setear variables de entorno
done

#TODO preguntar por ejecucion de RecibirOfertas

