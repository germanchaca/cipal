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
my $pathFechas=$PROCDIR."/validas/$fechaDeAdjudicacion.txt";
my $pathSorteos=$PROCDIR."/sorteos/$sorteo";
print $pathGrupos."\n";
print $pathPadrones."\n";
print $pathSorteos."\n";

if(not((-r $pathPadrones)and(-r $pathGrupos)and(-r $pathSorteos))){#and(-e $pathFechas)
	print	"ERROR: NO ESTAN TODOS LOS ARCHIVOS DE INGRESO\n";
    exit 1;
}

my %hashGrupos=&hashGrupos($pathGrupos);
my %hashSorteos=&hashSorteos($pathSorteos);
#print $hashGrupos{7886}[0]."\n";
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
			&GanadoresPorSorteo;
		}
		elsif($cadena eq "C"){
			print "Ganadores por licitacion\n";
			&GanadoresPorLicitacion;
		}
		elsif($cadena eq "D"){
			print "Resultado por grupo \n";
			&ResultadoPorGrupo;
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
	print "Holis\n";
		if($grabarBool){
		print "Grabo: ";
		print "$sorteoId"."_"."$fechaDeAdjudicacion.txt\n";
		&escribirArchivo("$sorteoId_$fechaDeAdjudicacion.txt",$texto)
	}
}
sub GanadoresPorLicitacion{
	print "Holis\n";
}
sub ResultadoPorGrupo{
	print "Holis\n";
}
sub hashSorteos{
	my %hashSorteos;
	($pathSorteos)=@_;
	print $pathSorteos."\n";
	open (my $handleSorteos,'<'.$pathSorteos) || die "ERROR: No puedo abrir el fichero $filename\n";
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
sub ayuda{
	print "ayuda\n";
}
sub opciones{
	print "Opciones Descripcion\nA \t Resultado General del sorteo\nB \t Ganadores por sorteo\nC \t Ganadores por licitacion\nD \t Resultado por grupo \nexit \t Para salir\n-a: \t repetir este mensaje\n";
}
sub hashGrupos{
	my %hashGrupos;
	($pathGrupos)=@_;
	open (my $handleGrupos,'<'.$pathGrupos) || die "ERROR: No puedo abrir el fichero $filename\n";
	while ($linea=<$handleGrupos>){
		chomp($linea);
		my @listCsv=split(/;/,$linea);
		my $key=shift(@listCsv);
		$hashGrupos{$key} = [@listCsv];
	}
	close $handleGroup;
	return %hashGrupos;
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
	my $writemod="> ";
	my $filename = $INFODIR."/".$argumentos[0];
	open ($file,$writemod.$filename) || die "ERROR: No puedo abrir el fichero $filename\n";
	print $file $argumentos[1];
	close($file);


}
#open my $handle, '<', $path_to_file;
#chomp(my @lines = <$handle>);
#close $handle;

#BEGIN { print "empezamos ...\n";}
#	END { print "nos fuimos \n"}