#Falta ver que este inicializado el ambiente
#Antes de iniciarlo me fijo que no es te corriendo.
proceso=$@
#Me fijo la cantidad de parametros
uno=1
if [ "$#" -gt "$uno" ]
then
	echo "Cantidad de parametros incorrecta"
	exit
fi
#Me fijo que exista el proceso
if [ ! -f $proceso ]
then
	echo "Proceso no existe"
	exit
fi
#Me fijo que tenga permisos de ejecucion
if [ ! -x $proceso ]
then
	echo "Proceso no tiene permisos de ejecucion"
	exit
fi
corriendo=false
while read -r linea
do
	p=${linea%% *}
	if [ $p == $proceso ]
	then
		echo Fallo la inicializacion. El proceso ya se encontraba corriendo
		corriendo=true
	fi
done < procesos
if [ $corriendo = false ]
then
	./"$proceso" &
	echo $proceso $!  >> procesos
	echo Inicializacion exitosa. El proceso $proceso esta corriendo
fi
