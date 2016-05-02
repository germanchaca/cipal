#!/bin/bash

Mensaje () {
   	./GrabarBitacora.pl RecibirOfertas $1 $2
}
#$1 dir con el file
#$2 destino
MoverArchivo(){
	./MoverArchivos.sh $1 $NOKDIR "RecibirOfertas"
}
case $(ps -o stat= -p $$) in
  *+*) background=0 ;;
  *) background=1 ;;
esac
padre=$(ps -o stat= -p $PPID)
er1='Ss'
er2='Ss+'
if [ $background -eq 0 ]
then 
	echo "RecibirOfertas solo corre en background"
	exit
fi
if [ "$padre" == "$er2" ]
then
	echo "RecibirOfertas solo se puede invocar desde LanzarProceso o InicializarAmbiente"
	exit
fi
cont=0
while true
do
	cont=$((cont+1))
	Mensaje "Corrida numero: $cont" "INFO"
	for arch in $(ls $ARRIDIR)
	do
		dir="$ARRIDIR/$arch"
		extension=${arch##*.}
		text='csv'
		#Que sea un texto
		if [ "$extension" == "$text" ]
		then
			#Que no sea vacio
			if [ -s $dir ]
			then
				#Que tenga permisos de lectura
				if [ -f $dir ] 
				then
					#Que tenga formato correcto
					re="^[0-9]*_[0-9]{8}.*$"
					if [[ $arch =~ $re ]]
						then
						#Me fijo que tenga un codigo valido
						codigoValido=false
						codArch=${arch%%_*}
						if [ ! -f "$MAEDIR/concesionarios.csv" ]
						then
							Mensaje "No existe $MAEDIR/concesionarios.csv" "ERR"
							exit
						fi
						while read -r linea
						do
							cod=${linea##*;}
							if [ $codArch -eq $cod ]
							then
								codigoValido=true
							fi
						done < "$MAEDIR/concesionarios.csv"
						if [ $codigoValido == true ]
						#Si es valido el codigo, me fijo que pasa con la fecha
						then
							aux=${arch#*_}
							fecha=${aux%%.*}
							fechaActual=$(date +%Y%m%d)
							if [ $fecha -le $fechaActual ]
							then
								if  date --date $fecha >/dev/null 2>&1;
								then
									#Me dijo que este despues del acto de adjudicacion anterior
									if [ ! -f "$MAEDIR/FechasAdj.csv" ]
									then
										Mensaje "No existe $MAEDIR/FechasAdj.csv" "ERR"
										exit
									fi
									anterior=1
									while read -r i
									do
										fechaAux=${i%%;*}
										fechaAux="${fechaAux///}"
										fechaAux=$(echo $fechaAux | sed "s-\([0-3][0-9]\)\([0-1][0-9]\)\([0-9]\{4\}\)-\3\2\1-g")
										if [ $fechaActual -gt $anterior -a $fechaAux -gt $fechaActual ]
										then
											actoAnterior=$anterior
										fi
										anterior=$fechaAux
									done < "$MAEDIR/FechasAdj.csv" 
									if [ $fecha -gt $actoAnterior ]
									then
										./MoverArchivos.sh $dir $OKDIR
										Mensaje "$arch movido a $OKDIR" "INFO"
									else
										Mensaje "La fecha de $arch es anterior al ultimo acto de adjudicacion" "ERR"
										MoverArchivo $dir
									fi
								else
									Mensaje "$arch fecha invalida" "ERR"
									MoverArchivo $dir
								fi
							else
								Mensaje "$arch es del futuro" "ERR"
								MoverArchivo $dir
							fi
						else
							Mensaje "$arch codigo invalido" "ERR"
							MoverArchivo $dir
						fi
					else
						Mensaje "$arch formato Incorrecto" "ERR"
						MoverArchivo $dir
					fi
				else
					Mensaje "$arch no tiene permisos de lectura" "ERR"
					MoverArchivo $dir
				fi
			else
				Mensaje "$arch esta vacio" "ERR"
				MoverArchivo $dir
			fi
		else
			Mensaje "$arch no es un texto" "ERR"
			MoverArchivo $dir
		fi
	done

	#Me fijo canidad de archivos en OK
	cant=$(ls -1 $OKDIR | wc -l)
	cero=0
	if [ $cant -gt $cero ]
	then
		salida=$(./LanzarProceso.sh ProcesarOfertas.sh)
		Mensaje "LanzarOfertas: $salida""INFO"
	fi
	sleep $SLEEPTIME
done
