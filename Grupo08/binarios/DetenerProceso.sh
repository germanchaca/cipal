proceso=$@
#Me fijo la cantidad de parametros
uno=1
if [ "$#" -gt "$uno" ]
then
	echo "Cantidad de parametros incorrecta"
	exit
fi
encontro=false
while read -r linea
do
	cod=${linea##* }
	p=${linea%% *}
	if [ $p == $proceso ]
	then
		kill $cod
		echo Proceso Eliminado
		encontro=true
	fi
done < procesos
if [ $encontro = false ]
then
	echo No se encontro proceso
else
	sed -i "/$proceso/d" procesos
fi