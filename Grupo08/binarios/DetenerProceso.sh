#!/bin/bash

proceso=$@
#Me fijo la cantidad de parametros
uno=1
if [ "$#" -gt "$uno" -o "$#" -eq 0 ]
then
	echo "Cantidad de parametros incorrecta"
	exit
fi
encontro=false
for i in $(ps -ef -o comm)
do
	aux=${proceso%.*}
	if [ $i == $aux ] 
	then
		encontro=true
		pid=$(pidof -x $proceso)
		kill $pid
	fi
done
if [ $encontro = false ]
then
	echo No se encontro proceso
else
	echo Proceso $proceso terminado.
fi