#!/bin/bash
#
# Universidad de Buenos Aires
# Facultad de Ingenieria
#
# 75.08 Sistemas Operativos
# Grupo: 08
#
#Parametros: 
#		-a: Ayuda
# Input:
# 	1.Tabla de Fechas de adjudicacion MAEDIR/Fechas_Adj.csv
# Output:
# 	1.Archivos de sorteos PROCDIR/sorteos/<sorteoId>_<fecha de adjudicación >
# 	2.Log del Comando LOGDIR/GenerarSorteo.log



function intruirModoLlamada(){
	echo "Modo de llamada a funcion bash: GenerarSorteo.sh"
	exit 1
}
function mostrarAyuda(){
	echo "GenerarSorteo:"
	echo "El propósito de este comando es generar números aleatorios sin repetición del 1 al 168"	
	echo "Deben de estar inicializadas las variables de ambiente"
	echo "Modo de llamada a funcion bash: GenerarSorteo.sh "	
	echo "Graba el resultado de cada sorteo para cada fecha de adjudicacion en bitacora y archivo de /sorteos/<sorteoId>_<fecha de adjudicación>"
	exit 0
}
function checkearEntornoNoIniciado(){
	if [ -z "$BINDIR"  -o -z "$MAEDIR"  -o -z "$PROCDIR" ] ; then
		echo "Error: No estan inicializadas las variables de entorno "
		exit 1
	fi	
}

#Parametros:
#		1.mensaje a guardar en bitacora
#		2.tipo de mensaje (INFO, WAR, ERR)
function grabarBitacora() {
	local command="GenerarSorteo"
  	local msj=$1
	local msj_type=$2
  	$GRABITAC "$command" "$msj" "$msj_type"
}

function crearDirOutputSorteosSiNoExiste(){
	if [ ! -d $PROCDIR"sorteos" ]
	then
		mkdir -p $PROCDIR"sorteos"
	fi
}

function inicializarLog(){
	grabarBitacora "Inicio de Sorteo" "INFO"
}

function finalizarLog(){
	grabarBitacora "Fin de Sorteo" "INFO"
}
function checkearExistenciaTablaFechasAdj(){
	if [ ! -f "$TABLA_FECHAS_ADJ" ];
	then
		grabarBitacora "No existe el archivo $TABLA_FECHAS_ADJ" "ERR"
		echo "No existe el archivo $TABLA_FECHAS_ADJ"
		exit 1
	fi
}
function chkExistFncShGrabarBitacora(){
	if [ ! -f "$GRABITAC" ];
	then
		echo "Error: No existe el archivo $GRABITAC"
		exit 1
	fi
}

#Parametros:
#		1.numero de orden
#		2.numero de sorteo correspondiente al numero de orden
function escribirLineaArchivo(){
	echo "$1;$2\n">>$fileNameSorteo
}

#COMIENZA MAIN
[[ $1 == "-a" ]] && mostrarAyuda
[[ $# -gt 0 ]] && intruirModoLlamada

checkearEntornoNoIniciado
TEMP="GrabarBitacora.pl"
GRABITAC="$BINDIR$TEMP"
chkExistFncShGrabarBitacora

TEMP="FechasAdj.csv"
TABLA_FECHAS_ADJ="$MAEDIR$TEMP"
checkearExistenciaTablaFechasAdj

crearDirOutputSorteosSiNoExiste

#Me quedo con el primer campo del archivo csv con las fechas de adjudicacion, delimitado con ';'
fechasActoAdjudicacion=$(cut "$TABLA_FECHAS_ADJ" -d';' -f1) 

inicializarLog
#inicializamos el sorteoId en 1
sorteoId=1

for fecha in $fechasActoAdjudicacion
do
	sorteo=$(seq 168 | shuf) #Generador de numeros aleatorios del 1 al 168

	fechaModificada=${fecha////-} #FORMATO DD-MM-YYYY

	TEMP="sorteos/$sorteoId""_""$fechaModificada.srt"

	fileNameSorteo="$PROCDIR$TEMP"

	#Si ya esta creado lo renombra con .old
	if [ -w $fileNameSorteo ]
	then
		mv $fileNameSorteo $fileNameSorteo".old"
	fi

	nroOrden=1
	for nroSorteo in $sorteo
	do
		grabarBitacora "Numero de orden $nroOrden \t le corresponde el numero de sorteo $nroSorteo" "INFO"
		escribirLineaArchivo "$nroOrden" "$nroSorteo"
		nroOrden=$((nroOrden+1))
	
	done
	sorteoId=$((sorteoId+1))
done
finalizarLog
#FIN MAIN



