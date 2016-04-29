#Falta ver que este inicializado el ambiente
proceso=$2
background=$1
parametroCorrecto=-b
#Me fijo la cantidad de parametros
dos=2

#Me fijo quien lo llama
padre="$(ps -o comm= $PPID)"

#Metodo de salida
#$1 mensaje
Mensaje () {
    if [ "$padre" == "bash" ]
    then
   		echo "Lanzar Proceso:" $1
   	else
   		echo $1
   	fi
   	exit
}

if [ "$#" -gt "$dos" -o "$#" -eq 0 ]
then
	Mensaje "Cantidad de parametros incorrecta"
fi
if [ "$#" -eq "$dos" ]
then
	proceso=$2
	background=$1
	if [ ! "$background" == "$parametroCorrecto" ]
	then
		Mensaje "Flag incorrecto, el Unico posible es -b"
	fi
else
	proceso=$1
fi
#Me fijo que exista el proceso
if [ ! -f $proceso ]
then
	Mensaje "Proceso no existe"
fi
#Me fijo que tenga permisos de ejecucion
if [ ! -x $proceso ]
then
	Mensaje "Proceso no tiene permisos de ejecucion"
fi
#Antes de iniciarlo me fijo que no es te corriendo.
for i in $(ps -L u n )
do
	if [[ $i == $proceso ]]; then
		Mensaje "Proceso $proceso ya se encuentra corriendo"
	fi
done
if [ $background == "-b" ]
then
	sh "$proceso" &
	Mensaje "Inicializacion exitosa. El proceso $proceso esta corriendo en background. Numero de proceso: $!"
else
	sh "$proceso"
	Mensaje "Inicializacion exitosa. El proceso $proceso esta corriendo."
fi
