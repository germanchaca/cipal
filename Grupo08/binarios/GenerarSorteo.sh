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

SEP=";"
padre=$(ps -o stat= -p $PPID)
er1='Ss'
er2='Ss+'
if [ "$padre" == "$er1" ]
then
	echo "GenerarSorteo solo se puede invocar desde LanzarProceso"
	exit
fi


function fechaActual {
	DATE=$(date +%d/%m/%Y)
}

function proximaFechaAdj {
	fechaActual
	IANIO=2
	IMES=1
	IDIA=0
	local array_fecha=(${DATE//// })
	local nextDate=$(grep "[0-3][0-9]/${array_fecha[$IMES]}/${array_fecha[$IANIO]}${SEP}.*" "${MAEDIR}/FechasAdj.csv")
	local nextDay=${nextDate%%/*}
	if [ ! $nextDay -gt ${array_fecha[$IDIA]} ]; then
		local mesSiguiente=$(( ${array_fecha[$IMES]} + 1 ))
		if [ 10 -gt $mesSiguiente ];then
			mesSiguiente="0${mesSiguiente}"
		fi
		nextDate=$(grep "[0-3][0-9]/$mesSiguiente/${array_fecha[$IANIO]}${SEP}.*" "${MAEDIR}/FechasAdj.csv")
	fi
	PROXADJ=${nextDate%%${SEP}*}
	PROXADJ=${PROXADJ////-}
}

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
	if [ ! -d $PROCDIR"/sorteos" ]
	then
		mkdir -p $PROCDIR"/sorteos"
	fi
}

function inicializarLog(){
	grabarBitacora "Inicio de Sorteo id: $1" "INFO"
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
	echo "$1;$2">>$fileNameSorteo
}

#COMIENZA MAIN
[[ $1 == "-a" ]] && mostrarAyuda
[[ $# -gt 0 ]] && intruirModoLlamada

checkearEntornoNoIniciado
TEMP="/GrabarBitacora.pl"
GRABITAC="$BINDIR$TEMP"
chkExistFncShGrabarBitacora

TEMP="/FechasAdj.csv"
TABLA_FECHAS_ADJ="$MAEDIR$TEMP"
checkearExistenciaTablaFechasAdj

crearDirOutputSorteosSiNoExiste

#Me quedo con el primer campo del archivo csv con las fechas de adjudicacion, delimitado con ';'
fechasActoAdjudicacion=$(cut "$TABLA_FECHAS_ADJ" -d';' -f1) 

 
#inicializamos el sorteoId en 1

max=0
for i in $(ls $PROCDIR/sorteos)
do
	id=${i%%_*}
	if [ $id -gt $max ]
	then
		max=$id
	fi
done
sorteoId=$((max+1))
#for fecha in $fechasActoAdjudicacion
#do
	inicializarLog "$sorteoId"

	sorteo=$(seq 168 | shuf) #Generador de numeros aleatorios del 1 al 168

	#fechaModificada=${fecha////-} #FORMATO DD-MM-YYYY
	proximaFechaAdj

	TEMP="/sorteos/$sorteoId""_""$PROXADJ.srt"

	fileNameSorteo="$PROCDIR$TEMP"

	#Si ya esta creado lo renombra con .old
	if [ -w $fileNameSorteo ]
	then
		rm $fileNameSorteo
	fi

	nroOrden=1
	for nroSorteo in $sorteo
	do
		grabarBitacora "Numero de orden $nroOrden \t le corresponde el numero de sorteo $nroSorteo" "INFO"
		escribirLineaArchivo "$nroOrden" "$nroSorteo"
		nroOrden=$((nroOrden+1))
	
	done
	sorteoId=$((sorteoId+1))
#done
finalizarLog
#FIN MAIN



