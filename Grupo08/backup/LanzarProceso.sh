#Falta ver que este inicializado el ambiente
#Antes de iniciarlo me fijo que no es te corriendo.
proceso=$2
background=$1

#Me fijo la cantidad de parametros
dos=2
if [ "$#" -gt "$dos" ]
then
	echo "Cantidad de parametros incorrecta"
	exit
fi
if [ "$#" -eq "$dos" ]
then
	proceso=$2
	background=$1
else
	proceso=$1
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
for i in $(ps -L u n )
do
	if [[ $i == $proceso ]]; then
		echo Proceso $proceso ya se encuentra corriendo
		exit
	fi
done
if [ $background == "-b" ]
then
	sh "$proceso" &
	echo Inicializacion exitosa. El proceso $proceso esta corriendo en background. Numero de proceso: $!
else
	sh "$proceso"
	echo Inicializacion exitosa. El proceso $proceso esta corriendo.
fi
