MAEDIR=/home/federico/Escritorio/cipal/Grupo08/maestros
ARRIDIR=/home/federico/Escritorio/cipal/Grupo08/arribados
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
				#Me fijo que tenga un codigo valido
				valido=false
				codArch=${arch%%_*}
				while read -r linea
				do
					cod=${linea##*;}
					if [ $codArch -eq $cod ]
					then
						valido=true
						echo $arch tiene codigo correcto
					fi
				done < "$MAEDIR/concesionarios.csv"
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
