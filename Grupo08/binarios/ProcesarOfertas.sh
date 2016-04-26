#! bin/bash
#mis variables para ir probando
OKDIR="../aceptados"
MAEDIR="../maestros"
PROCDIR="../procesados"
NOKDIR="../rechazados"
LOGDIR="../bitacoras" 

LOGSIZE=10000
export LOGDIR
export LOGSIZE

#empieza mi programa de verdad
PROCEAROFERTAS='ProcesarOfertas'
GRABAR='perl GrabarBitacora.pl ProcesarOfertas'
ROWSEXPECTED=2

ERR_MSG=''

PROCESADOS=0
RECHAZADOS=0
MALOFERTA=0
BIENOFERTA=0

ERROR=1
OK=0

ICONTFUS=0
IIMPORTE=1
IPARTICIPA=2

SEP=";"

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

function writeLineTo {
	#$1 line $2 archivo
	if [ ! -f $1 ]; then
		touch $1
	fi
	echo $2 >> $1
}

function just_name {
	#$1 path
	local name=${1##*/}
	local just_name=${name%%.*}
	echo -n $just_name
}

function validCONTFUS {
	ESTADO=1
	if [[ "$1" =~ [0-9]{7} ]]; then
		local grupo=$(echo -n $1 | head -c 4 )
		local orden=$(echo -n $1 | tail -c 3 )
		local subscrpitor=$(grep "${grupo}${SEP}${orden}${SEP}.*" "${MAEDIR}/temaL_padron.csv")
		local grupos=$(grep "${grupo}${SEP}.*" "${MAEDIR}/grupos.csv")
		local array_grupo=(${grupos//$SEP/ })
		if [ -z "$subscrpitor" ];then
			ERR_MSG="Contrato no encontrado"
			return $ERROR
		elif [ ${array_grupo[$ESTADO]} = "CERRADO" ];then
			ERR_MSG="Grupo CERRADO"
			return $ERROR
		else
			return $OK
		fi
	else
		ERR_MSG="El contrato fusionado no tiene 7 caracteres"
		return $ERROR
	fi
}

function validIMPORTE {
	if [[ "$1" =~ [0-9]+ ]]; then
		#validar contra >= a cuota_pura * cantidad_cuotas para licitacion
		# <= a vouta_pura * cuotas_pendientes ?? de donde sale --> grupo
		#error con sobre o bajo
		return $OK
	else
		ERR_MSG="No es un numero el importe"
		return $ERROR
	fi
}

function validPARTICIPA {
	#buscar campo numero X en subscriptos
	PARTICIPA=5
	local array_subscriptor=(${1//$SEP/ })
	if [[ "${array_subscriptor[$PARTICIPA]}" =~ ^[12]$ ]]; then
		return $OK
	else
		ERR_MSG='No puede participar'
		return $ERROR
		
	fi
}

function validOFERTA {
	local array=(${1//$SEP/ })
	validCONTFUS ${array[$ICONTFUS]}
	if [ $? = $ERROR ];	then
		return $ERROR
	fi
	validIMPORTE ${array[$IIMPORTE]}
	if [ $? = $ERROR ]; then
		return $ERROR
	fi
	local grupo=$(echo -n ${array[$ICONTFUS]} | head -c 4 )
	local orden=$(echo -n ${array[$ICONTFUS]} | tail -c 3 )
	local subscrpitor=$(grep "${grupo}${SEP}${orden}${SEP}.*" "${MAEDIR}/temaL_padron.csv")
	validPARTICIPA "$subscrpitor"
	if [ $? = $ERROR ]; then
		return $ERROR
	else 
		return $OK
	fi
}

ICODCONS=0
IFECHA=1

function errorRegistro {
	#file $1,  linea $2
	local name=$(just_name $1)
	local array=(${name//_/ })
	local cod_concesionario=${array[ICODCONS]}
	fechaActual
	local line="${name}${SEP}${ERR_MSG}${SEP}'${2}'${SEP}${USER}${SEP}${DATE}"
	writeLineTo "${PROCDIR}/rechazadas/${cod_concesionario}.rech" "$line"
	let 'MALOFERTA++'
}

function bienRegistro {
	#file $1,  linea $2
	NAME=2
	local file_name=$(just_name $1)
	local array=(${file_name//_/ })
	local array_line=(${2//$SEP/ })
	local contratoFusionado=${array_line[$ICONTFUS]}
	local grupo=$(echo -n $contratoFusionado | head -c 4 )
	local orden=$(echo -n $contratoFusionado | tail -c 3 )
	local subscrpitor=$(grep "${grupo}${SEP}${orden}${SEP}.*" "${MAEDIR}/temaL_padron.csv")
	local array_subscriptor=(${subscrpitor//$SEP/ })
	local name=${array_subscriptor[$NAME]}
	fechaActual
	proximaFechaAdj
	local line="${array[$ICODCONS]}${SEP}${array[$IFECHA]}${SEP}${contratoFusionado}${SEP}${grupo}${SEP}${orden}${SEP}${array_line[IIMPORTE]}${SEP}${name}${SEP}${USER}${SEP}${DATE}"
	writeLineTo "${PROCDIR}/validas/${PROXADJ}.csv" $line
	let 'BIENOFERTA++'
}

function finArchivo {
	if [ $2 = $ERROR ]; then
		let 'RECHAZADOS++'
		#mover $1 a ${NOKDIR}
	else
		let 'PROCESADOS++'
		#mover $1 a ${PROCDIR}/procesadas
	fi
}

$GRABAR "Inicio de ${PROCEAROFERTAS}"

ofertas="${OKDIR}/*_*.csv"
countOfertas=$(ls -1  $ofertas | wc -l)

$GRABAR "Cantidad de archivos a procesar: ${countOfertas}"

for file in $ofertas
do
	if [ -f "${PROCDIR}/procesadas/${file##*/}" ]
		then
		$GRABAR "Se rechaza el archivo '${file##*/}' por estar duplicado"
		echo "DUPLICADO"
		finArchivo $file $ERROR
	else
		#primer fila de file, deja comas y \n, cuenta bytes
		first_row=$(head -1 $file)
		campos=(${first_row//$SEP/ })
		if [ ${#campos[@]} = $ROWSEXPECTED ]
			then
			echo "PROCESANDO"
			$GRABAR "Archivo a procesar: ${file##*/}"

			for line in $(<$file)
			do
				validOFERTA $line
				if [ $? = $OK ]; then
					bienRegistro $file $line 
				else
					errorRegistro $file $line 
				fi				
			done
			
			TOTAL=$(($BIENOFERTA + $MALOFERTA))
			$GRABAR "Registros leidos = ${TOTAL}: cantidad de ofertas validas ${BIENOFERTA}: cantidad de ofertas rechazadas = ${MALOFERTA}"
			finArchivo $file $OK
		else
			echo "MAL FORMATO DE ARCHIVO"
			$GRABAR "Se rechaza el archivo '${file##*/}' porque su estructura no se corresponde con el formato esperado"
			finArchivo $file $ERROR
		fi
		
	fi
	TOTAL=0
	MALOFERTA=0
	BIENOFERTA=0
	
done

$GRABAR "Archivos procesados: ${PROCESADOS}: Archivos rechazados: ${RECHAZADOS}"

$GRABAR "Fin de ProcesarOfertas"