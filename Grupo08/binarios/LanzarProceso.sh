proceso=$2
background=$1
parametroCorrecto=-b
#Me fijo la cantidad de parametros
dos=2

#Me fijo quien lo llama
padre="base"
#Metodo de salida
#$1 mensaje
#$2 tipo
Mensaje () {
    if [ "$padre" == "bash" ]
    then
   		echo "Lanzar Proceso:" $1
   	else
   		#Aca graba bitacora
   		#echo $1
   		echo $1
   		#./GrabarBitacora.pl LanzarProceso $1 $2
   	fi
   	exit
}

if [ "$#" -gt "$dos" -o "$#" -eq 0 ]
then
	Mensaje "Cantidad de parametros incorrecta" "ERR"
fi
if [ "$#" -eq "$dos" ]
then
	proceso=$2
	background=$1
	if [ ! "$background" == "$parametroCorrecto" ]
	then
		Mensaje "Flag incorrecto, el Unico posible es -b" "ERR"
	fi
else
	proceso=$1
fi
#Me fijo que exista el proceso
if [ ! -f $proceso ]
then
	Mensaje "Proceso no existe" "ERR"
fi
#Me fijo que tenga permisos de ejecucion
if [ ! -x $proceso ]
then
	Mensaje "Proceso no tiene permisos de ejecucion" "ERR"
fi
#Me fijo que este inicializado el ambiente
if [ ! -z "$OKDIR" ] 
then
	Mensaje "El ambiente no se ecuentra inicializado" "ERR"
fi
#Antes de iniciarlo me fijo que no es te corriendo.
for i in $(ps -L u n )
do
	if [[ $i == $proceso ]] 
	then
		Mensaje "Proceso $proceso ya se encuentra corriendo" "ERR"
	fi
done
if [ $background == "-b" ]
then
	sh "$proceso" &
	Mensaje "Inicializacion exitosa. El proceso $proceso esta corriendo en background. Numero de proceso: $!" "INFO"
else
	sh "$proceso"
	Mensaje "Inicializacion exitosa. El proceso $proceso esta corriendo." "INFO"
fi
