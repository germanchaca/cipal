#! bin/bash
#mis variables para ir probando
OKDIR="../OKDIR"
MAEDIR="../MAEDIR"
PROCDIR="../PROCDIR"
NOKDIR="../NOKDIR"
LOGDIR="../LOGDIR" 

LOGSIZE=10000
export LOGDIR
export LOGSIZE

#empieza mi programa de verdad
PROCEAROFERTAS='ProcesarOfertas'
GRABAR='perl GrabarBitacora.pl ProcesarOfertas'
ROWSEXPECTED=3

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

function fecha {
	DATE=$(date +%d/%m/%Y)
}

function just_name {
	#$1 path
	local name=${1##*/}
	local just_name=${name%%.*}
	echo -n $just_name
}

function validCONTFUS {
	if [[ "$1" =~ [0-9]{7} ]]; then
		return $OK
		#validar contrato encontrado!!!
		#validar grupo si esta CERRADO NO! contra MAEDIR/Grupos.csv (grep)
		#error con grupo cerrado
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
	if [[ "$1" =~ ^[12]$ ]]; then
		#buscar en padron de subscriptores
		return $OK
	else
		ERR_MSG='No puede participar'
		return $ERROR
		
	fi
}

function validOFERTA {
	#split a linea
	local array=(${1//,/ })
	validCONTFUS ${array[ICONTFUS]}
	if [ $? = $ERROR ];	then
		return $ERROR
	fi
	validIMPORTE ${array[IIMPORTE]}
	if [ $? = $ERROR ]; then
		return $ERROR
	fi
	validPARTICIPA ${array[IPARTICIPA]}
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
	fecha
	echo "${name},${ERR_MSG},'${2}',${USER},${DATE}"
	#fijarse caso crear si no existe
	#escribir en ${PROCDIR}/rechazadas/cod_concesionario.rech(primer parte del nombre de file)
	let 'MALOFERTA++'
}

function bienRegistro {
	#file $1,  linea $2
	local file_name=$(just_name $1)
	local array=(${file_name//_/ })
	local array_line=(${2//,/ })
	local contratoFusionado=${array_line[$ICONTFUS]}
	local grupo=$(echo -n $contratoFusionado | head -c 4 )
	local orden=$(echo -n $contratoFusionado | tail -c 3 )
	fecha
	#fijarse caso crear si no existe
	#a grabar en fecha de adjudicacion (proxima fecha) en ${PROCDIR}/validas
	#falta el ${nombre_subs} del q oferta
	#nombre subscrpitor, ir a temaL_padron.csv para buscar, saco donde esta con los grupos
	echo "${array[$ICODCONS]},${array[$IFECHA]},${contratoFusionado},${grupo},${orden},${array_line[IIMPORTE]},${USER},${DATE}"
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
		rows=$(head -1 $file | sed 's/[^,]//g' | wc -c)
		if [ $rows = $ROWSEXPECTED ]
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