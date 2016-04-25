#!/bin/bash

#Parametros: 
#		-a: Ayuda
# Input:
# 	1.Tabla de Fechas de adjudicacion MAEDIR/fechas_adj.csv
# Output:
# 	1.Archivos de sorteos PROCDIR/sorteos/<sorteoId>_<fecha de adjudicación >
# 	2.Log del Comando LOGDIR/GenerarSorteo.log

function intruirModoLlamada(){
	echo "Modo de llamada a funcion bash: GenerarSorteo.sh \n"
	exit 1
}
function mostrarAyuda(){
	echo "GenerarSorteo:\n"
	echo "El propósito de este comando es generar números aleatorios sin repetición del 1 al 168\n"	
	echo "Deben de estar inicializadas las variables de ambiente\n"
	echo "Modo de llamada a funcion bash: GenerarSorteo.sh \n"	
	echo "Graba el resultado de cada sorteo para cada fecha de adjudicacion en bitacora y archivo de /sorteos/<sorteoId>_<fecha de adjudicación>\n"
	exit 0
}
function checkearEntornoNoIniciado(){
	if [ -z "$BINDIR" ] -o [-z "$MAEDIR"] -o [-z "$PROCDIR"]; then
		echo "Error: No estan inicializadas las variables de entorno \n"
		exit 1
	fi	
}
function existeArchivo(){
	local nombreArchivo="$1" #recibe parametro posicional 1
	[[ -f "$nombreArchivo" ]] && return 0 || return 1
}

#Parametros:
#		1.mensaje a guardar en bitacora
#		2.tipo de mensaje (INFO, WAR, ERR)
function grabarBitacora() {
	local command="GenerarSorteo"
  	local msj=$1
	local msj_type= $2
  	$GRABITAC "$command" "$msj" "$msj_type"
}

function crearDirOutputSorteosSiNoExiste(){
	mkdir -p "$PROCDIR/sorteos"
}

function inicializarLog(){
	grabarBitacora "Inicio de Sorteo" "INFO"
}

function finalizarLog(){
	grabarBitacora "Fin de Sorteo" "INFO"
}
function checkearExistenciaTablaFechasAdj(){
	if (!existeArchivo "$TABLA_FECHAS_ADJ")
	then
		grabarBitacora "No existe el archivo $TABLA_FECHAS_ADJ" "ERR"
		echo "No existe el archivo $TABLA_FECHAS_ADJ \n"
		exit 1
	fi
}
function chkExistFncShGrabarBitacora(){
	if (!existeArchivo "$GRABITAC")
	then
		echo "Error: No existe el archivo $GRABITAC \n"
		exit 1
	fi
}

#Parametros:
#		1.numero de orden
#		2.numero de sorteo correspondiente al numero de orden
function escribirLineaArchivo(){
	echo "$1;$2\n">> $fileNameSorteo
}

#COMIENZA MAIN
[ [ $1 == "-a" ] -a [ $# -eq 1 ]] && mostrarAyuda
[[ $# -gt 0 ]] && instruirModoLlamada

checkearEntornoNoIniciado

GRABITAC = "$BINDIR/GrabarBitacora.sh"
chkExistFncShGrabarBitacora

TABLA_FECHAS_ADJ = "$MAEDIR/FechasAdj.csv"
checkearExistenciaTablaFechasAdj

crearDirOutputSorteosSiNoExiste

#Me quedo con el primer campo del archivo csv con las fechas de adjudicacion, delimitado con ';'
fechasActoAdjudicacion=$(cut "$TABLA_FECHAS_ADJ" -d';' -f1) 

inicializarLog
#inicializamos el sorteoId en 1
sorteoId= 1

for fecha in $fechasActoAdjudicacion
do
	sorteo = $(seq 168 | shuf) #Generador de numeros aleatorios del 1 al 168

	fileNameSorteo = "$PROCDIR/sorteos/$sorteoId_$fecha.srt"
	touch $fileNameSorteo #vacia el archivo si existe y lo crea

	nroOrden = 1
	for nroSorteo in $sorteo
	do
		grabarBitacora "Numero de orden $nroOrden \t le corresponde el numero de sorteo $nroSorteo\n" "INFO"
		escribirLineaArchivo "$nroOrden" "$nroSorteo"

		nroOrden = $(($nroOrden + 1))
	done
	sorteoId = $(($sorteoId + 1))
done
finalizarLog
#FIN MAIN



