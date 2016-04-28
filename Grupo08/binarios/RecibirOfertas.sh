MAEDIR=../maestros
ARRIDIR=../arribados
OKDIR=../aceptados
for arch in $(ls $ARRIDIR)
do
	dir="$ARRIDIR/$arch"
	extension=${arch##*.}
	text="txt"
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
						echo No existe $MAEDIR/concesionarios.csv
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
									echo No existe $MAEDIR/FechasAdj.csv
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
									echo "$arch es correcto -> Moverlo"
								else
									echo "La fecha de $arch es anterior al ultimo acto de adjudicacion"
								fi
							else
								echo $arch fecha invalida
							fi
						else
							echo $arch es del futuro
						fi
					else
						echo $arch codigo invalido
					fi
				else
					echo $arch formato Incorrecto
				fi
			else
				echo "$arch no tiene permisos de lectura"	
			fi
		else
			echo "$arch esta vacio"
		fi
	else
		echo "$arch no es un texto"
	fi
done

#Me fijo canidad de archivos en OK
cant=$(ls -1 $OKDIR | wc -l)
cero=0
if [ $cant -gt $cero ]
then
	salida=$(./LanzarProceso.sh ProcesarOfertas)
	echo LanzarOfertas: $salida 
fi