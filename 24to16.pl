#!/usr/bin/perl

#use strict;
#use warnings;

while(1)
{
    
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
