#!/usr/bin/perl
if((not defined $ENV{'LOGDIR'}) or (not defined $ENV{'LOGSIZE'})){
	print	"ERROR: NO ESTAN DEFINIDAS LAS VARIABLES DE AMBIENTE\n";
    exit 1;
}
$LOGDIR =  $ENV{'LOGDIR'}; 
$LOGSIZE =  $ENV{'LOGSIZE'}; 
$log="";
#print "LOGDIR, $LOGDIR\n"; 
#print "LOGSIZE, $LOGSIZE\n";
($command, $msj, $msj_type) = @ARGV;
#print "comando, $command \n";
#print "mensaje, $msj \n";
if (opendir ( DIR, $LOGDIR ) ){
	#print "existe $LOGDIR\n";
}else{
	print "No existe $LOGDIR\n";
}

$filename = $LOGDIR."/".$command.".log";
#print "filename , $filename\n";

if(-e $filename){
	#print "existe\n";
	$writemod=">> ";
}else{
	#print "no existe\n";
	$writemod="> ";
}
open ($log,$writemod.$filename) || die "ERROR: No puedo abrir el fichero $filename\n";
$logname = getlogin();
$time_stamp=&time_stamp;
$type=&msj_type($msj_type);
#print "tipo_de_mensaje, $type \n";

print $log "DATE:$time_stamp-USER:$logname-CMD:$command-TYPE:$type-MSJ:$msj \n";
$tamanio=`wc -l $filename`;
@tamanio = split(" ", $tamanio);
$tamanio=@tamanio[0];
#print "tamanio $tamanio \n";
#print "LOGSIZE $LOGSIZE \n";

if( $tamanio >= $LOGSIZE){
	print $log "Log Excedido \n";
	`sed -i 1d  $filename`;
	`sed -i 1d  $filename`;

}
close($log);

sub time_stamp {
$logname = getlogin();
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,
$isdst)=localtime;
$year+=1900;
$mon++;
$time_stamp= "$mday/$mon/$year $hour:$min:$sec";
return ($time_stamp);
}
sub msj_type {
	my $type=$_[0];
	if(($type eq "WAR") or($type eq "ERR") ) {
		return $type;
	}
	$type="INFO";
	return($type);
}
