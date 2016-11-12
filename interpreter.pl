#!/usr/bin/perl -w
# interpreter.pl --- Интерпретатор Brainfuck
# Author:  <Ayrat.Salavatovich@analyst.mx>
# Created: 12 Nov 2016
# Version: 0.01

use warnings;
use strict;
use v5.14;

use Getopt::Long;
use Pod::Usage;

sub interpret {
    my ( $input ) = @_;
    my @input = split //, $input;
    my @tape = ( 0 ) x 30000;    

    # Set the pointer to point at the left most cell of the tape.
    my $ptr = 0;

    my $current_char;
    for (my $i = 0; $i < @input; $i++) {
        $current_char = $input[$i];
        # Операторы перемещения указателя
        if    ( $current_char eq '>' ) {
            $ptr++;
        }
        elsif ( $current_char eq '<' ) {
            $ptr--;
            die "Pointer cannot go below 0" if $ptr < 0; 
        }
        # Инкремент и декремент
        elsif ( $current_char eq '+' ) {
            $tape[$ptr]++;
            $tape[$ptr] = 0 if $tape[$ptr] > 255;
        }
        elsif ( $current_char eq '-' ) {
            $tape[$ptr]--;
            $tape[$ptr] = 255 if $tape[$ptr] < 0;
        }
        # Ввод и вывод
        elsif ( $current_char eq '.' ) { print chr($tape[$ptr])         }
        elsif ( $current_char eq ',' ) { $tape[$ptr] = ord(getc(STDIN)) }
        # Операторы цикла
        elsif ($current_char eq '[' ) {
            # если значение текущей ячейки нулевое, перейти вперёд к оператору ] (с учётом вложенности)
            unless ( $tape[$ptr] ) {
                my $loop = 1;
                while ( $loop > 0 ) {
                    $current_char = $input[++$i];
                    if ( $current_char eq ']' ) {
                        $loop--;
                    } elsif ( $current_char eq '[' ) {
                        $$loop++;
                    }
                }
            }
        }
        elsif ( $current_char eq ']' ) {
            # если значение текущей ячейки не нулевое, перейти назад к оператору [ (c учётом вложенности)
            if ( $tape[$ptr] ) {
                my $loop = 1;
                while ( $loop > 0 ) {
                    $current_char = $input[--$i];
                    if ( $current_char eq '[' ) {
                        $loop--;
                    } elsif ( $current_char eq ']' ) {
                        $loop++;
                    }
                }
            }
        }
    }
}

sub check_exists {
    my ( $files ) = @_;
    for ( @$files ) {
        die "'$_' does not exist" unless -f;
    }
}

sub execute {
    my ( $files ) = @_;
    
    for my $file ( @$files ) {
        my $code = undef;
        {
            local $/ = undef;
            open my $fh, '<', $file;
            $code = <$fh>;
            close $fh;
        }
        interpret $code if $code;
    }
}

sub main {
    my @files;
    my $man = 0;
    my $help = 0;
    
    GetOptions ( "files|f=s" => \@files,
                 "<>" => sub { push @files, @_ },
                 "help|?" => \$help,
                 man => \$man)
        or pod2usage(2);
    
    pod2usage(1) if $help;
    pod2usage(-exitval => 0, -verbose => 2) if $man;
    die "Usage: interpret inputfiles" unless @files;

    check_exists \@files;
    execute \@files;
}

&main;

__END__

=head1 NAME

interpreter.pl - Brainfuck interpreter written in Perl

=head1 SYNOPSIS

interpreter.pl [options] files ...

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

Stub documentation for interpreter.pl, 

=head1 AUTHOR

Ayrat Salavatovich, E<lt>Ayrat.Salavatovich@analyst.mxE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by 

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
