#!/usr/bin/perl 

#Detalization manager
#v0.6
#Author: Alexey Uchakin a.k.a. Snake
#Company: Obit
#20120510
#Absolutely no warranty

use strict;
use Net::Whois::IANA;
use Net::CIDR;
use Getopt::Long;

################## Parsing options ##################
my ($file, $out, $depth, $num_str, $iplist, $source, $sourceport, $dest, $destport);
my $result = GetOptions (
    "file=s" => \$file,
    "netlist=s" =>\$out,
    "iplist=s"=>\$iplist,
    "depth=s" =>\$depth,
    "number=s" =>\$num_str,
    "source=s" =>\$source,
    "destination=s" =>\$dest,
    "srcport=s" =>\$sourceport,
    "dstport=s" =>\$destport,
    );

if(!$file) {die "Please, use --file option!\n";}
if(!$out) {$out = "report_by_net_".$file;}
if(!$iplist) {$iplist = "report_by_ip_".$file;}
if (!$depth) {$depth=0;}
elsif (!($depth =~ m/[MmKkGg][Bb]/)){die "Please use KB, MB or GB notation\n";}
elsif ($depth =~ m/[Kk][Bb]/){$depth = 1000;}
elsif ($depth =~ m/[Mm][Bb]/){$depth = 1000000;}
elsif ($depth =~ m/[Gg][Bb]/){$depth = 1000000000;}
if(!$num_str) {$num_str=0;}
################## Parsing file ##################
open(f,$file) or die "Can't open file: $!";
my $str;
my %totalbyip;
my %nets;
my %nettraf;
my @cidr_list = ("10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12");
my %cidr;
#my ($a, $b);
my $iana = new Net::Whois::IANA;
print "Open file: $file\n";
while($str = <f>){
    chomp($str);
    my ($starttime, $endtime, $sif, $srcip, $srcport, $dif, $dstip, $dstport, $p, $fl, $pkt, $oct) = $str =~ /(.*?)\s+(.*?)\s+(\d+)\s+(.{15})\s+(\d+)\s+(\d+)\s+(.{15})\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+).*?/;   
    $srcip =~ s/\s//g;
    	if (Net::CIDR::cidrvalidate($srcip)){
		if (!exists($totalbyip{$srcip})) {$totalbyip{$srcip} = 0;}
		if (!$sourceport || ($sourceport == $srcport)){$totalbyip{$srcip} += int($oct);}
		if (!$destport || ($destport == $dstport)){$totalbyip{$srcip} += int($oct);}
	}
}
close(f);
print "Generate statistic by IP\n";
################## Statistic by IP ##################
open(l,">$iplist") or die "Can't open file: $!\n";
my @iplist = sort {$totalbyip{$b} <=> $totalbyip{$a}} keys %totalbyip;
if($source && Net::CIDR::cidrvalidate($source)){print l "$source; $totalbyip{$source} bytes\n";}
elsif ($num_str != 0){
	for (my $j=0; $j<$num_str; $j++){
		print l "$iplist[$j]: $totalbyip{$iplist[$j]} bytes\n";
	}
}else{
	foreach (sort {$totalbyip{$b} <=> $totalbyip{$a}} keys %totalbyip){print l "$_: $totalbyip{$_} bytes\n";}
}
close(l);
######################################################
open (w,">cidr.txt");
print "File is loaded and parsed. Calculating statistic...\n";

foreach my $ip (sort keys %totalbyip){
	my ($netname, @netnum, @cidr, $look);
	foreach my $name (sort keys %nets){
		if($look = Net::CIDR::cidrlookup($ip, @{$nets{$name}})){
                       $nettraf{$name} += $totalbyip{$ip};
                       last;
                }
	}
	if($look) {next;}
	else{
		$iana->whois_query(-ip=>$ip) or die "Can't whois: $!";
		$netname = $iana->netname();
        	@netnum = $iana->inetnum();
		@cidr = Net::CIDR::range2cidr(@netnum) or die "Incorrect CIDR Range: $!\n";
		#print w "Add net @cidr for $netname\n";
		foreach (@cidr) {
			if (!($_ =~ m/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d{1,2})$/))
			{
				if($_ =~ m/^(\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d{1,2})$/)
				{
					$_ = ("$1".'.0/'."$2");
				}
				elsif($_ =~ m/^(\d{1,3}\.\d{1,3})\/(\d{1,2})$/)
				{
					$_ = ("$1".'.0.0/'."$2");
				}
				elsif($_ =~ m/^(\d{1,3})\/(\d{1,2})$/)
				{
					$_ = ("$1".'.0.0.0/'."$2");
				}
			}
		}
                if ($nets{$netname}) {
                	push @cidr, @{$nets{$netname}};}
                $nets{$netname} = \@cidr;
		push @cidr_list, @cidr;
		if (!exists($nettraf{$netname})) {$nettraf{$netname} = 0;}
		$nettraf{$netname} += $totalbyip{$ip};
	}
}
print "Writing to cache...\n";
foreach my $net (sort keys %nets){
	print w "$net: @{$nets{$net}}\n";
}
close(w);

print "Count complete\n";
################## Statistic by NET ##################
open(o,">$out") or die "Can't open output file: $!\n";
my @netlist = sort {$nettraf{$b} <=> $nettraf{$a}} keys %nettraf;
if ($num_str != 0){
        for (my $k=0; $k<$num_str; $k++){
		if(int($nettraf{$netlist[$k]}) > int($depth)){
                	print o "NET: $netlist[$k]; Traffic: $nettraf{$netlist[$k]} bytes\n";
		}
        }
}else{
        foreach (@netlist){
		if(int($nettraf{$netlist[$_]}) > int($depth)){
			print o "NET: $_; Traffic: $nettraf{$_} bytes\n";
		}
	}
}
close(o);
######################################################
