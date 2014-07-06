#!/usr/bin/perl

use strict;
use warnings;

print "Enter a 24bit color value (eg. 7fff00), program will output a 16bit hex color value\n";

while(1)
{
    print "> ";    
    my $input = <STDIN>;
    
    if($input =~ /([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])/)
    {
    
        my $red = $1; my $green = $2; my $blue = $3;
        
        
        my $output = (( hex $red ) >> 3) << 11;
        $output += ((hex $green) >> 2) << 5;
        $output += ((hex $blue) >> 3);
        
        printf "%x\n", $output;
    
    }
}
