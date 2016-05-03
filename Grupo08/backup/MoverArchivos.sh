#! /bin/bash

#ACA EMPIEZA
NOGRABA=0
GRABA=1
ERROR=1
OK=0
LLAMADOR=''
MODO=3

if [ ! "$INICIALIZADO" = 1 ];then
	echo "No esta inicializado el ambiente"
	exit $ERROR
fi

function logear {
	if [ $MODO = $GRABA ]; then
		perl GrabarBitacora.pl "$LLAMADOR" "$1"
	fi
}

function getMaxSeqArch {
	#obtiene el numero del proximo archivo
	local numbers_array=($(ls $1 | grep "${FILENAME}\..*" | sed "s-\(.*\.\)\([0-9]\+\)-\2-"))
	local number=$(( 1 + ${#numbers_array[@]}))
	echo $number
		
}

function salirError {
	#duplico info pero dice escribir resultado
	logear "$1"
	perl GrabarBitacora.pl MoverArchivos "$1" "ERR"
	
}

#Validaciones
if [[ $# -lt 2 ]]; then
	salirError "FALTAN ARGUMENTOS,total $#"
	exit $ERROR
elif [[ $# -gt 3 ]]; then
	salirError "SOBRAN ARGUMENTOS, total $#"
	exit $ERROR
elif [[ $# = 2 ]];then
	MODO=$NOGRABA
else
	MODO=$GRABA
	LLAMADOR="$3"
fi

if [ ! -f $1 ];then
	salirError "NO EXISTE ORIGEN"
	exit $ERROR
fi

if [ ! -d $2 ];then
	salirError "No existe el destino"
	exit $ERROR
fi

# para que el destino quede en formato /path/to/move/
lastCh=$((${#2}-1))
if [ lastCh = '/' ]; then
	DESTINDIR="$2"
else
	DESTINDIR="${2}/"
fi

#MoverArchivo
FILENAME="${1##*/}"
DESTINO="${DESTINDIR}${FILENAME}"
DIRDUPL="${DESTINDIR}dpl/"

if [ $1 = $DESTINO ];then
	logear "No movio ${FILENAME}, moviendo al mismo lugar"
	exit $OK
fi


if [ -f $DESTINO ];then

	if [ ! -d $DIRDUPL ];then
		mkdir $DIRDUPL
		if [ ! $? ];then
			salirError "Error creando directorio ${DIRDUPL}"
			exit $ERROR
		fi
	fi

	if [ -f "${DIRDUPL}${FILENAME}" ];then 
		#existe el duplicado
		SEQ=$(getMaxSeqArch "${DIRDUPL}")
		mv $1 "${DIRDUPL}${FILENAME}.${SEQ}"
		logear "Movio ${FILENAME} a ${DIRDUPL}, repeticion:${SEQ}"
	else
		mv $1 "${DIRDUPL}${FILENAME}"
		logear "Movio ${FILENAME} a ${DIRDUPL}"
	fi
else
	mv $1 $DESTINO
	logear "Movio ${FILENAME} a ${DESTINO}"
fi
