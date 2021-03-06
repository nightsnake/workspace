#!/usr/bin/perl
use strict;
use Image::ExifTool ':Public';
use Image::Magick;
use Getopt::Long;

# Constants
my %preferred_fonts = (
    'date' => [ qw/ Ubuntu DejaVuSans  DejaVu-Sans Bitstream-Vera-Sans BitstreamVeraSans Verdana / ], # Normal width
    'name' => [ qw/ Ubuntu DejaVuSansC DejaVu-Sans-Condensed Tahoma / ], # Narrow
    'site' => [ qw/ Ubuntu Bold DejaVuSansB BitstreamVeraSansB VerdanaB TahomaB / ], # Bold
);

#Fillcolor
my $color  = '#fff3';
#Textcolor
my $textclr = '#000000FF';
my $gap    = 2;
#my $name   = (getpwuid $>)[6];
#   $name   =~ s/,+$//;
my $name   = 'Alexey Uchakin |';
my $prefix = '_';
my $site   = 'http://night-snake.net';
my $size   = '1200';

# Override with options
GetOptions(
    'color:s'   => \$color,
    'gap:i'     => \$gap,
    'name:s'    => \$name,
    'prefix:s'  => \$prefix,
    'site:s'    => \$site,
    'size:s'    => \$size,
);

# Try to find suitable fonts
my $image = new Image::Magick;
my @available_fonts = $image->QueryFont();
my ( %seen, %fonts );
map { $seen{$_} = 1 } @available_fonts;

while ( my ( $scope, $list ) = each %preferred_fonts ) {
    foreach ( @$list ) {
        $fonts{ $scope } = $_
            and last
            if $seen{$_};
    } # foreach
} # while


foreach my $file ( @ARGV ) {
    my $info = ImageInfo($file, 'CreateDate');
    my $date = $$info{'CreateDate'};
    my $new_file_name = $file;
	my $new_name_no_logo = $file;
    $new_file_name =~ s{([^/]+)$}{$prefix$1};
    $new_name_no_logo =~ s{([^/]+)$}{$prefix$prefix$1};
    $date =~ s/^(\d{4}):(\d{2}):(\d{2}).*/$3.$2.$1/;

    my $p = new Image::Magick or next;
    $p->Read( $file );
#    $p->AutoOrient;
    #my ( $nx, $ny ) = $p->Get('width', 'height');
    my ($ox,$oy)=$p->Get('base-columns','base-rows');
    my ($nx, $ny);
    if ($ox > $oy){#Если ориентация горизонтальная
	$nx=$size;
	$ny=int(($oy/$ox)*$size); #вычисляем высоту, если ширину сделать size
    }else{#Или вертикальная
	$nx=int(($ox/$oy)*$size); #вычисляем ширину, если высоту сделать size
	$ny=$size;
    }
    $p->Resize(
        'geometry'  => 'geometry',
	'width'     => $nx, 
        'height'    => $ny,
    );

    my ( $width, $height ) = $p->Get('width', 'height');
    my ( $x, $y ) = ( 0, $height - $gap );
    
#Write background
    $p->Set(
        'pointsize'     => 14,
        'fill'          => $color,
    );
    my $recx = $x + 265; my $recy = $y - 14;
    $p->Draw(
	'primitive'	=>'rectangle', 
	'points'	=>"$x,$recy $recx,$height",
    );

#print "Draw from $x to $width and from $y to $height\n";
#Write text
    $p->Set(
        'pointsize'     => 14,
        'fill'          => $textclr,
    );
    
    $p->Annotate(
        'font'          => $fonts{'name'},
        'text'          => $name,
        'antialias'   	=> 'True',
        'rotate'        => 0,
        'x'             => $x,
        'y'             => $y,
    );
#	$p->Write($new_name_no_logo);
#    $y -= (
#        $p->QueryFontMetrics(
#            'font'          => $fonts{'name'},
#            'text'          => $name,
#        )
#    )[4] + $gap;
    $x += (
        $p->QueryFontMetrics(
            'font'          => $fonts{'site'},
            'text'          => $name,
        )
    )[4];

    $p->Annotate(
        'font'          => $fonts{'site'},
        'text'          => $site,
        'antialias'   	=> 'True',
        'rotate'        => 0,
        'x'             => $x,
        'y'             => $y,
    );
    
#Write file
    $p->Write($new_file_name);
    #print "$file - $date\n";
    
}
