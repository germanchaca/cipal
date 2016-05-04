#! /bin/bash

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

if [ ! "$INICIALIZADO" = 1 ];then
	echo "No esta inicializado el ambiente"
	exit $ERROR
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


function setVariablesOfertaDeArchivosMaestros {
	# $1 --> contrato fusiondo(grupo+orden)
	
	GRUPO=$(echo -n $1 | head -c 4 )
	ORDEN=$(echo -n $1 | tail -c 3 )
	SUBSCRIPTOROFERTA=$(grep "${GRUPO}${SEP}${ORDEN}${SEP}.*" "${MAEDIR}/temaL_padron.csv")
	GRUPOOFERTA=$(grep "${GRUPO}${SEP}.*" "${MAEDIR}/grupos.csv")

}

function validUser {
	local users=$(ls "$PROCDIR/validas/$PROXADJ.csv" | grep ".*${GRUPO}${ORDEN}.*")
	if [ ! $users eq "" ];then
		ERR_MSG="Persona ya oferto"
		return	$ERROR
	fi
	return $OK
}

function validCONTFUS {
	IESTADO=1
	if [[ "$1" =~ [0-9]{7} ]]; then
		local array_grupo=(${GRUPOOFERTA//$SEP/ })
		if [ -z "$SUBSCRIPTOROFERTA" ];then
			ERR_MSG="Contrato no encontrado"
			return $ERROR
		elif [ ${array_grupo[$IESTADO]} = "CERRADO" ];then
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
	ICUOTPURA=3
	ICUOTPEND=4
	ICUOTLIC=5
	if [[ "$1" =~ [0-9]+ ]]; then
		#validar contra >= a cuota_pura * cantidad_cuotas para licitacion
		# <= a vouta_pura * cuotas_pendientes ?? de donde sale --> grupo
		#error con sobre o bajo
		local array_grupo=(${GRUPOOFERTA//$SEP/ })
		local cuotaPura=${array_grupo[$ICUOTPURA]}
		local cuotasPend=${array_grupo[$ICUOTPEND]}
		local cuotasLic=${array_grupo[$ICUOTLIC]}
		cuotaPura=${cuotaPura//,/.}
		local maximo=$(echo "scale=2;${cuotaPura}*${cuotasPend}" | bc)
		local minimo=$(echo "scale=2;${cuotaPura}*${cuotasLic}" | bc)
		local importe=${1//,/.}
		if (( $(echo "${importe} > ${maximo}" | bc -l) )); then
			ERR_MSG="El importe supera el maximo a ofertar"
			return $ERROR
		elif (( $(echo "${importe} < ${minimo}" | bc -l) )); then
			ERR_MSG="El importe esta por debajo de lo minimo a ofertar"
			return $ERROR
		fi
		return $OK
	else
		ERR_MSG="No es un numero el importe"
		return $ERROR
	fi
}

function validPARTICIPA {
	#buscar campo numero X en subscriptos
	PARTICIPA=5
	local array_subscriptor=(${SUBSCRIPTOROFERTA//$SEP/ })
	if [[ "${array_subscriptor[$PARTICIPA]}" =~ ^[12]$ ]]; then
		return $OK
	else
		ERR_MSG='No puede participar'
		return $ERROR
		
	fi
}

function validOFERTA {
	local array=(${1//$SEP/ })
	setVariablesOfertaDeArchivosMaestros ${array[$ICONTFUS]}
	validUser
	if [ $? = $ERROR ]; then
		return $ERROR	
	fi
	validCONTFUS ${array[$ICONTFUS]}
	if [ $? = $ERROR ];	then
		return $ERROR
	fi
	validIMPORTE ${array[$IIMPORTE]}
	if [ $? = $ERROR ]; then
		return $ERROR
	fi
	validPARTICIPA
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
	local array_subscriptor=(${SUBSCRIPTOROFERTA//$SEP/ })
	local name=${array_subscriptor[$NAME]}
	local fecha_original=$(echo ${array[$IFECHA]} | sed "s/^\([0-9]\{4\}\)\([01][0-9]\)\([0-3][0-9]\)$/\3-\2-\1/" )
	fechaActual
	proximaFechaAdj
	local line="${array[$ICODCONS]}${SEP}${fecha_original}${SEP}${contratoFusionado}${SEP}${GRUPO}${SEP}${ORDEN}${SEP}${array_line[$IIMPORTE]}${SEP}${name}${SEP}${USER}${SEP}${DATE}"
	writeLineTo "${PROCDIR}/validas/${PROXADJ}.csv" "$line"
	let 'BIENOFERTA++'
}

function finArchivo {
	if [ $2 = $ERROR ]; then
		let 'RECHAZADOS++'
		./MoverArchivos.sh $1 ${NOKDIR} "ProcesarOfertas"
	else
		let 'PROCESADOS++'
		./MoverArchivos.sh $1 ${PROCDIR}/procesadas "ProcesarOfertas"
		#mover $1 a ${PROCDIR}/procesadas
	fi
}


#Programa principal
$GRABAR "Inicio de ${PROCEAROFERTAS}"

ARCHIV=$(ls $OKDIR)
if [ ! "$ARCHIV" ]; then
	$GRABAR "$OKDIR VACIO"
	exit
fi

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
		#obtiene primer fila y arma array de elementos
		first_row=$(head -1 $file)
		campos=(${first_row//$SEP/ })
		if [ ${#campos[@]} = $ROWSEXPECTED ]
			then
			echo "PROCESANDO"
			$GRABAR "Archivo a procesar: ${file##*/}"

			for line in $(<$file)
			do
				#archivos windows !!
				line=${line//^M/}
				line=$(echo $line | tr -d '\r')
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
