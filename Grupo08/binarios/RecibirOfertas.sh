MAEDIR=/home/federico/Escritorio/cipal/Grupo08/maestros
ARRIDIR=/home/federico/Escritorio/cipal/Grupo08/arribados
OKDIR=/home/federico/Escritorio/cipal/Grupo08/aceptados
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
								echo $arch esta en fecha
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
cant=$(ls -1 $OKDIR | wc -l)
cero=0
if [ $cant -gt $cero ]
then
	salida=$(./LanzarProceso.sh proceso)
	echo $salida posta
fi