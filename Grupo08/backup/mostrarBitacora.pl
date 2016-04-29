#!/usr/bin/perl
#Parametros: 
#		1.nombre de comando(obligatorio)
#		2.string a buscar(opcional)
#		3.ruta destino de la consulta - alli se muestra la bitacora(opcional)
# Ejemplo de uso:
#		mostrarpathBitacora.pl "RecibirOfertas" "archivo"
#		 20150905 19:53:22-Sandra-RecibirOfertas-WAR-No se pudo mover el archivo


#COMIENZA Main
$LOGDIR =  $ENV{'LOGDIR'};
@listLineas = '';

#Carga de parametros pasados
$comando = $ARGV[0];	# Nombre de comando, obligatorio.
if (defined $ARGV[1] && length $ARGV[1] > 0) {
	$stringDeConsulta = $ARGV[1];	# String a buscar, opcional.
}
if (defined $ARGV[2] && length $ARGV[2] > 0) {
	$filePathDestino =  $ARGV[2];
}

$pathBitacora = $LOGDIR."/". $comando . ".log";

if(-e $pathBitacora){ 
	#si existe el archivo
	open (BITACORA, "<$pathBitacora") || die "ERROR: No puedo abrir el fichero $pathBitacora\n ";


	while ($linea=<BITACORA>) {
		if (defined $stringDeConsulta) {
			if ($linea =~ /$stringDeConsulta/) {
				&mostrarLinea ($linea);
			}
		} else {
			&mostrarLinea ($linea);
		}
	}

	#escribe el archivo  destino de haber pasado la ruta del mismo como parametro opcional
	if (defined $filePathDestino) {
		open (SALIDA, ">$filePathDestino") || die "Error: No se pudo escibir el fichero $filePathDestino \n ";
		foreach $linea (@listLineas){
			 print SALIDA $linea;		
		}
		close (SALIDA);
	}
	close (BITACORA);
}else{
	print "ERROR: No existe el archivo log para el comando ". $comando;
}
#FIN Main

#Imprime por pantalla la linea que se pasa por parametro
sub mostrarLinea {
	my ($linea) = @_;
	if (defined $filePathDestino) {
		push(@listLineas,$linea);
	}else{
		print "$linea";
	}
        
}
