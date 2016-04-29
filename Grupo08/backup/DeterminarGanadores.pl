#!/usr/bin/perl
$MAEDIR =  $ENV{'MAEDIR'}; 
$PROCDIR =  $ENV{'PROCDIR'}; 
$INFODIR =  $ENV{'INFODIR'}; 
my $grabarBool="0";
if((length($MAEDIR) eq 0) or (length ($PROCDIR) eq 0)or (length ($INFODIR) eq 0)){
	print	"ERROR: NO ESTAN DEFINIDAS LAS VARIABLES DE AMBIENTE\n";
    exit 1;
}
if (@ARGV[0] eq "-a"){
	print "ayuda\n";
	exit 0;
}
if (@ARGV[0] eq "-g"){
	print "grabo\n";
	$grabar="1";
	shift(@ARGV);
}else{
	print "no grabo\n";
	$grabar="0";
}

my $sorteoId=shift(@ARGV);
my @grupos = &listaGrupos(@ARGV);
my $sorteo="";
my $fechaDeAdjudicacion="";
my $regEx= qr/$sorteoId/;
#/**Busco el archivo de sorteo y la fechaDeAdjudicacion**/
if (opendir(DIR,"./$PROCDIR/sorteos")){
	while( $filename = readdir(DIR)){
		if($filename =~ /$regEx/){
			$sorteo=$filename;
			last;
		}
	}	
	closedir(DIRH);
}else{
	print "ERROR:NO HAY SORTEOS\n";
	exit 1;
}

if( length($sorteo) eq 0){
	print "ERROR:NO HAY SORTEO CON EL ID DADO\n";
	exit 1;
}
print "Sorteo".$sorteo."\n";
#my @sorteoList = split(/.txt/, $sorteo);
my @fechaDeAdjudicacionList = split("_", $sorteoList[0] );
my $fechaDeAdjudicacion= $fechaDeAdjudicacionList[1];

my $pathPadrones="./".$MAEDIR."/temaL_padron.csv.xls";
my $pathGrupos="./".$MAEDIR."/grupos.csv.xls";
my $pathFechas="./".$PROCDIR."/validas/$fechaDeAdjudicacion.txt";
my $pathSorteos="./".$PROCDIR."/sorteos/$sorteo";
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
print "Opciones Descripcion\nA \t Resultado General del sorteo\nB \t Ganadores por sorteo\nC \t Ganadores por licitacion\nD \t Resultado por grupo \nexit \t Para salir\n";
while ($cadena ne "exit") {
	print "Ingresa tu opcion: ";
	$cadena = <STDIN> ;
	chop($cadena);
	print "Has escrito $cadena\n";
		if($cadena eq "exit"){print "Hasta luego\n"}
		if($cadena eq "A"){
			print "Resultado General del sorteo\n";
			&ResultadoGeneralDelSorteo(\%hashSorteos);
		}
		if($cadena eq "B"){
			print "Ganadores por sorteo\n";
			&GanadoresPorSorteo;
		}
		if($cadena eq "C"){
			print "Ganadores por licitacion\n";
			&GanadoresPorLicitacion;
		}
		if($cadena eq "D"){
			print "Resultado por grupo \n";
			&ResultadoPorGrupo;
		}
}

sub ResultadoGeneralDelSorteo{
	print "Holis\n";
	my ($hashSorteos) = @_;
	foreach $key (sort { $a <=> $b } (keys(%$hashSorteos)))#ordena numericamente
	{
		print "Nro. de Sorteo $key, le correspondió al número de orden $hashSorteos{$key}\n";
	}
}
sub GanadoresPorSorteo{
	print "Holis\n";
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
	open (my $handleSorteos,'<'.$pathSorteos) || die "ERROR: No puedo abrir el fichero $filename\n";
	while ($linea=<$handleSorteos>){
		chomp($linea);
		my @listCsv=split(/ /,$linea);
		my $numeroDeOrden=$listCsv[3];
		my $numeroDeSorteo=$listCsv[10];
		$hashSorteos{$numeroDeSorteo} = $numeroDeOrden;
		#print "Nro. de Sorteo $numeroDeSorteo, le correspondió al número de orden $numeroDeOrden\n";
	}
	close $handleSorteos;
	return %hashSorteos;
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
	print "Holis";
	my (@argumentos) = @_;
	my @grupos;
	foreach $grupo (@argumentos){
		print "grupo: ".$grupo."\n";
		print "index: ".index($grupo,"-",0)."\n";
		if (index($grupo,"-",0) ne "-1"){
			print"inside\n";
			($inicial,$final)=split(/-/,$grupo);
			print $inicial."/".$final."\n";
			for (my $i=$inicial; $i<$final+1; $i++) {
				print $i."\n";
				push(@grupos, $i);
			}
		}else{
			print $grupo."\n";
			push(@grupos, $grupo);
		}
	}
	return (@grupos);
}
#open my $handle, '<', $path_to_file;
#chomp(my @lines = <$handle>);
#close $handle;

#BEGIN { print "empezamos ...\n";}
#	END { print "nos fuimos \n"}