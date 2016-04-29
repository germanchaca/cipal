proceso=$@
#Me fijo la cantidad de parametros
uno=1
if [ "$#" -gt "$uno" ]
then
	echo "Cantidad de parametros incorrecta"
	exit
fi
encontro=false
result=$(ps -L u n | tr -s " " | cut -d " " -f3,14- | grep $proceso)
cant=$(echo $result | wc -w)
if [ $cant -gt 3 ]
then
	encontro=true
	pid=${result%% *}
	kill $pid
fi
if [ $encontro = false ]
then
	echo No se encontro proceso
else
	echo Proceso $proceso terminado.
fi