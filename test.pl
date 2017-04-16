#!/usr/bin/perl

$str = "0x8000000000000000";
$hexport = substr($str, 2, 8);
#$decport = unpack("N", pack("H16", "0x8000000000000000")); #Convert from HEX string to DEC
$decport = hex("40000000");
$binport = unpack("B24", pack("N", $decport)); #Convert from DEC to BIN
#$binport = unpack("B24", pack("H8", "0x80000000"));
print "DEC: $decport\n";
print "BIN: $binport\n";
