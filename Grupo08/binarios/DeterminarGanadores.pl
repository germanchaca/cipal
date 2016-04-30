#!/usr/bin/perl
my $NOMBRE_CMD="DeterminarGanadores";
if((not defined $ENV{'MAEDIR'}) or (not defined $ENV{'PROCDIR'})or (not defined $ENV{'INFODIR'})){
	print	"ERROR: NO ESTAN DEFINIDAS LAS VARIABLES DE AMBIENTE\n";
	system("./GrabarBitacora.pl", "$NOMBRE_CMD", "ERROR: NO ESTAN DEFINIDAS LAS VARIABLES DE AMBIENTE", "ERROR");
    exit 1;
}
$MAEDIR =  $ENV{'MAEDIR'}; 
$PROCDIR =  $ENV{'PROCDIR'}; 
$INFODIR =  $ENV{'INFODIR'}; 

if (@ARGV[0] eq "-a"){
	&ayuda;
	print "ayuda\n";
	exit 0;
}
if (@ARGV[0] eq "-g"){
	print "grabo\n";
	$grabarBool="1";
	shift(@ARGV);
}else{
	print "Opcion no grabo\n";
	$grabarBool="0";
}

my $sorteoId=shift(@ARGV);
my $sorteo="";
my $fechaDeAdjudicacion="";
#/**Busco el archivo de sorteo y la fechaDeAdjudicacion**/
if (opendir(DIR,"$PROCDIR/sorteos")){
	while( $filename = readdir(DIR)){
		if (index($filename, $sorteoId."_") == 0 ){
			$sorteo=$filename;
			last;
		}
	}	
	closedir(DIR);
}else{
	print "ERROR:NO HAY SORTEOS\n";
	system("perl GrabarBitacora.pl", "$NOMBRE_CMD", "ERROR:NO HAY SORTEOS", "ERROR");
	exit 1;
}
if( length($sorteo) eq 0){
	print "ERROR:NO HAY SORTEO CON EL ID DADO\n";
	exit 1;
}
my @grupos = &listaGrupos(@ARGV);
print "Sorteo: ".$sorteo."\n";
my $index_separtor = index($sorteo, "_");
my $index_subfix = index($sorteo, ".srt");
my $lenght_fecha= $index_subfix-$index_separtor;
my $fechaDeAdjudicacion= substr $sorteo,$index_separtor +1 ,$lenght_fecha -1 ;
print "fecha: ".$fechaDeAdjudicacion."\n";
my $pathPadrones=$MAEDIR."/temaL_padron.csv";
my $pathGrupos=$MAEDIR."/grupos.csv";
my $pathFechas=$PROCDIR."/validas/$fechaDeAdjudicacion.csv";
my $pathSorteos=$PROCDIR."/sorteos/$sorteo";
print $pathGrupos."\n";
print $pathPadrones."\n";
print $pathSorteos."\n";
print $pathFechas."\n";

if(not((-r $pathPadrones)and(-r $pathGrupos)and(-r $pathSorteos)and(-r $pathFechas))){#and(-e $pathFechas)
	print	"ERROR: NO ESTAN TODOS LOS ARCHIVOS DE INGRESO\n";
    exit 1;
}
my %hashSorteos=&hashSorteos($pathSorteos);
my %hashGrupos=&hashGrupos($pathGrupos);
my %hashPadron=&hashPadron($pathPadrones);
my %hashFechaDeAdjudicacion=&hashFechaDeAdjudicacion($pathFechas);
my @gruposOk;
foreach $grupo (@grupos) {
	if(defined $hashGrupos{$grupo}){
		push (@gruposOk,$grupo);
	}
}

$cadena = "";
&opciones;
while ($cadena ne "exit") {
	print "Ingresa tu opcion: ";
	$cadena = <STDIN> ;
	chop($cadena);
	print "Has escrito $cadena\n";
		if($cadena eq "exit"){print "Hasta luego\n"}
		elsif($cadena eq "A"){
			print "Resultado General del sorteo\n";
			&ResultadoGeneralDelSorteo(\%hashSorteos);
		}
		elsif($cadena eq "B"){
			print "Ganadores por sorteo\n";
			print "Ganadores del sorteo $sorteoId de fecha $fechaDeAdjudicacion\n";
			my $imprimo ="imprimir";
			&GanadoresPorSorteo(\%hashPadron,\%hashSorteos,\@gruposOk,$imprimo);
		}
		elsif($cadena eq "C"){
			print "Ganadores por licitacion\n";
			print "Ganadores por Licitación $sorteoId de fecha $fechaDeAdjudicacion\n";
			my $imprimo ="imprimir";
			&GanadoresPorLicitacion(\%hashFechaDeAdjudicacion,\%hashPadron,\%hashSorteos,\@gruposOk,$imprimo);
		}
		elsif($cadena eq "D"){
			print "Resultado por grupo \n";
			&ResultadoPorGrupo(\%hashFechaDeAdjudicacion,\%hashPadron,\%hashSorteos,\@gruposOk);
		}elsif($cadena eq "-a"){
			&opciones;
		}else{
			print "La opcion ingresada no es valida. Ingrese -a para ver las opciones validas \n";
		}
}

sub ResultadoGeneralDelSorteo{
	my ($hashSorteos) = @_;
	my $texto="";
	foreach $key (sort { $a <=> $b } (keys(%$hashSorteos))){#ordena numericamente{}
		my $linea= "Nro. de Sorteo $key, le correspondió al número de orden $hashSorteos{$key}\n";
		print $linea;
		$texto = $texto.$linea;	
	}
	if($grabarBool){
		print "Grabo: ";
		print "$sorteoId"."_"."$fechaDeAdjudicacion.txt\n";
		&escribirArchivo("$sorteoId_$fechaDeAdjudicacion.txt",$texto)
	}
}
sub GanadoresPorSorteo{
	my ($refhashPadron,$refhashSorteos,$refgrupos,$imprimo) = @_;
	my $texto="";
	my @grupos=@$refgrupos;
	my %hashPadron=%$refhashPadron;
	my %hashSorteos=%$refhashSorteos;
	my %hashGanador;
	my $filename="$sorteoId";
	my $texto="";
 	foreach $grupos (@gruposOk){
 		$filename=$filename.$grupo."-"
 	}
 	$filename=$filename."_"."$fechaDeAdjudicacion";
	foreach $grupo (@gruposOk){
		my @listaUsuarios;
		foreach $nombrePadron (keys(%hashPadron)){
			my $grupoPadron=@{$hashPadron{$nombrePadron}}[0];
			if ($grupo == $grupoPadron){
				push(@listaUsuarios,[@{$hashPadron{$nombrePadron}}]);
			}
		} 
		my $boolGano=0;
		foreach $key (sort { $a <=> $b } (keys(%hashSorteos))){#orden que indica el sorteo con el sorteoId y fecha que se pasan por paramtro
			foreach $user (@listaUsuarios){
				my @listUser = @{$user}; #le aclaro a perl que es una lista con los datos del uuario
				if($hashSorteos{$key}==$listUser[1]){#numero de orden
					$linea="Ganador por sorteo del grupo $grupo, Nro de orden $hashSorteos{$key}, $listUser[2] (N° de sorteo: $key)\n";
					$hashGanador{$grupo}=[$hashSorteos{$key},$listUser[2]];#guardo N de orden y el nombre
					$boolGano=1;
					$texto = $texto.$linea;	
					print "$imprimo \n";
					if($imprimo eq "imprimir"){
						print $linea;
					}
					last;
				}
			}
			if($boolGano==1){
				last;
			}
		}
	}
	if($grabarBool and ($imprimo eq "imprimir")){
		print "Grabo: ";
		print "$filename\n";
		&escribirArchivo("$filename",$texto)				
	}
	return %hashGanador;
}
sub GanadoresPorLicitacion{
	my ($refhashFecha,$refhashPadron,$refhashSorteos,$refgrupos,$imprimo) = @_;
	my $texto="";
	my @grupos=@$refgrupos;
	my %hashFecha=%$refhashFecha;
	my %hashSorteos=%$refhashSorteos;
	my %hashPadron=%$refhashPadron;
	my %hashNOrden;
	my %hashGanador;

	foreach $numeroDeSorteo (keys(%hashSorteos)){
		$hashNOrden{$hashSorteos{$numeroDeSorteo}}=$numeroDeSorteo;
	}
	my $filename="$sorteoId";
	my $texto="";
 	my %hashGanadoresPorSorteo=	&GanadoresPorSorteo(\%hashPadron,\%hashSorteos,\@gruposOk,"no imprimir");
 	foreach $grupos (@gruposOk){
 		$filename=$filename.$grupo."-";
 	}
 	$filename=$filename."_"."$fechaDeAdjudicacion";
	foreach $grupo (@gruposOk){
		my @listaUsuarios;
		foreach $nombrePadron (keys(%hashFecha)){
			my $grupoPadron=@{$hashFecha{$nombrePadron}}[3];
			if ($grupo == $grupoPadron){
				push(@listaUsuarios,[@{$hashFecha{$nombrePadron}}]);
			}
		} 
		$numeroDeOrden;
		$nombre;
		$ofertaMax=0;
		foreach $user (@listaUsuarios){
			my @listUser = @{$user}; #le aclaro a perl que es una lista con los datos del uuario
			if($ofertaMax < $listUser[5]){#Importe Ofertado
				if(($ofertaMax==$listUser[5])and($hashNOrden{$numeroDeOrden} < $hashNOrden{$listUser[4]})and($numeroDeOrdenGanadorPorSorteo!=$listUser[4])){#Si es la misma oferta pero el numero de sorteo es mayor que al actual se mantiene el actual. Tampoco puede ser el ganador del soreteo
					next;
				}
				$ofertaMax=$listUser[5];
				$nombre=$listUser[6];
				$numeroDeOrden=$listUser[4];
			}
		}
		$hashGanador{$grupo}=[$numeroDeOrden,$nombre ];#guardo N de orden y el nombre
		print "@{$hashGanadoresPorSorteo{$grupo}}[0]"."\n";
		$linea="Ganador por licitación del grupo $grupo: Numero de orden $numeroDeOrden, $nombre con $ofertaMax (Nro de Sorteo $hashNOrden{$numeroDeOrden})\n";
		$texto = $texto.$linea;	
		if ($imprimo eq "imprimir"){
			print $linea;
		}
	}
	if($grabarBool and ($imprimo eq "imprimir")){
		print "Grabo: ";
		print "$filename\n";
		&escribirArchivo("$filename",$texto);					
	}
	return %hashGanador;
}
sub ResultadoPorGrupo{
	my ($refhashFecha,$refhashPadron,$refhashSorteos,$refgrupos,$imprimo) = @_;
	my @grupos=@$refgrupos;
	my %hashFecha=%$refhashFecha;
	my %hashSorteos=%$refhashSorteos;
	my %hashPadron=%$refhashPadron;
	my $imprimo ="no imprimir";
	%hashGanadoresPorSorteo=&GanadoresPorSorteo(\%hashPadron,\%hashSorteos,\@gruposOk,$imprimo);
	%hashGanadoresPorLicitacion=&GanadoresPorLicitacion(\%hashFechaDeAdjudicacion,\%hashPadron,\%hashSorteos,\@gruposOk,$imprimo);
	print "Ganadores por Grupo en el acto de adjudicación de fecha $fechaDeAdjudicacion, Sorteo: $sorteoId \n";
	foreach $grupo (@grupos){
		$nombreGanadorSorteo=@{$hashGanadoresPorSorteo{$grupo}}[1];
		$nombreGanadorLicitacion=@{$hashGanadoresPorLicitacion{$grupo}}[1];
		$numOrdenGanadorSorteo=@{$hashGanadoresPorSorteo{$grupo}}[0];
		$numOrdenGanadorLicitacion=@{$hashGanadoresPorLicitacion{$grupo}}[0];
		$linea= " $grupo-$numOrdenGanadorSorteo S ($nombreGanadorSorteo)\n $grupo-$numOrdenGanadorLicitacion L ($nombreGanadorLicitacion)\n";
		print $linea;
		if($grabarBool){
			my $filename="$sorteoId"."_"."Grupo"."$grupo"."_"."$fechaDeAdjudicacion";
			print "Grabo: ";
			print "$filename\n";
			&escribirArchivo("$filename",$linea)				
	}

	}

}
sub hashSorteos{
	my %hashSorteos;
	($pathSorteos)=@_;
	print "Path sorteos: ".$pathSorteos."\n";
	open (my $handleSorteos,'<'.$pathSorteos) || die "ERROR: No puedo abrir el fichero $pathSorteos\n";
	while ($linea=<$handleSorteos>){
		chomp($linea);
		my @listCsv=split(/;/,$linea);
		my $numeroDeOrden=$listCsv[1];
		my $numeroDeSorteo=$listCsv[0];
		$hashSorteos{$numeroDeSorteo} = $numeroDeOrden;
		#print "Nro. de Sorteo $numeroDeSorteo, le correspondió al número de orden $numeroDeOrden\n";
	}
	close $handleSorteos;
	return %hashSorteos;
}
sub hashPadron{
	#Key nombre, Value= info padron
	my %hashPadron;
	($pathPadrones)=@_;
	print "Path padrones: ".$pathPadrones."\n";
	open (my $handlePadron,'<'.$pathPadrones) || die "ERROR: No puedo abrir el fichero $pathPadrones\n";
	while ($linea=<$handlePadron>){
		chomp($linea);
		my @listCsv=split(/;/,$linea);
		my $participa=$listCsv[5];
		if(($participa!=1) and ($participa!=2)){ #ESTOS son los que nos son validos
			next;
		}
		$hashPadron{$listCsv[2]}=[@listCsv];
	}
	close $handlePadron;
#	foreach $key (keys(%hashPadron)){#ordena numericamente{}
#		print "Nombre $key ,Datos:  @{$hashPadron{$key}} \n";
#	}
	return %hashPadron;
}
sub ayuda{
	print "ayuda\n";
}
sub opciones{
	print "Opciones Descripcion\nA \t Resultado General del sorteo\nB \t Ganadores por sorteo\nC \t Ganadores por licitacion\nD \t Resultado por grupo \nexit \t Para salir\n-a: \t repetir este mensaje\n";
}
sub hashGrupos{
	my %hashGrupos;
	($pathGrupos)=@_;
	open (my $handleGrupos,'<'.$pathGrupos) || die "ERROR: No puedo abrir el fichero $pathGrupos\n";
	while ($linea=<$handleGrupos>){
		chomp($linea);
		my @listCsv=split(/;/,$linea);
		my $estado= $listCsv[1];
		if($estado eq "CERRADO"){
			next;
		}
		my $key=shift(@listCsv);#numero de grupo
		$hashGrupos{$key} = [@listCsv];
	}
	close $handleGroup;

	#foreach $key (keys(%hashGrupos)){#ordena numericamente{}
	#	print "Numero $key , Estado @{$hashGrupos{$key}} \n";
	#}

	return %hashGrupos;
}
sub hashFechaDeAdjudicacion{
	my %hashFechaDeAdjudicacion;
	($pathFechas)=@_;
	print "Path fechas: ".$pathFechas."\n";
	open (my $handleFechas,'<'.$pathFechas) || die "ERROR: No puedo abrir el fichero $pathFechas\n";
	while ($linea=<$handleFechas>){
		chomp($linea);
		my @listCsv=split(/;/,$linea);
		my $nombre=$listCsv[6];
		$hashFechaDeAdjudicacion{$nombre}=[@listCsv];
	}
	close $handleFechas;

	#foreach $key (keys(%hashFechaDeAdjudicacion)){#ordena numericamente{}
	#	print "Nombre $key ,Datos:  @{$hashFechaDeAdjudicacion{$key}} \n";
	#}
	return %hashFechaDeAdjudicacion;

}	
sub listaGrupos{
	my (@argumentos) = @_;
	my @grupos;
	foreach $grupo (@argumentos){
		if (index($grupo,"-",0) ne "-1"){
			($inicial,$final)=split(/-/,$grupo);
			for (my $i=$inicial; $i<$final+1; $i++) {
					push(@grupos, $i);
			}
		}else{
			push(@grupos, $grupo);
		}
	}
	sort {$a <=> $b} $grupos;
	print "Grupos Participantes: ";
	foreach $grupo (@grupos){
		print "$grupo,";
	}
	if(not @grupos){
		print "Todos"
	}
	print "\n";
	return (@grupos);
}
sub escribirArchivo{
	my (@argumentos) = @_;
	if (not opendir ( DIR, $INFODIR ) ){
		print "No existe $INFODIR\n";
		exit 1;
	}
	my $writemod;
	my $filename = $INFODIR."/".$argumentos[0];
	if(-e $filename){
	#print "existe\n";
		$writemod=">> ";
	}else{
	#print "no existe\n";
	$writemod="> ";
	}
	open ($file,$writemod.$filename) || die "ERROR: No puedo abrir el fichero $filename\n";
	print $file $argumentos[1];
	close($file);


}
#open my $handle, '<', $path_to_file;
#chomp(my @lines = <$handle>);
#close $handle;

#BEGIN { print "empezamos ...\n";}
#	END { print "nos fuimos \n"}