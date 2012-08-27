#!/usr/bin/perl
# Copyright (c) 2012-01-02 Ada <perl01@live.cn>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Documentation (at end) improved 2011 by Ada <perl01@live.cn>.


use strict;
#use warnings;
use XML::Simple;

chdir "/ada" or die "Can't Change to Target Path: $!\n";

open my $fh,">>","script.log" or die "Can't Write To Log File: $!\n";
open(STDERR,">/ada/error.log") or die "Can't Write To Log File: $!\n";
open(OUTCOPY,">&STDOUT") or die "Can't copy fh: $!\n";
open(STDOUT,">/ada/fs_std.out") or die "Can't Rewrite: $!\n";

my @time = split /\s+/,localtime();
my $simple = XML::Simple->new();
my $ra = $simple->XMLin("fs_conf_v_test.xml",ForceArray => 1);
=head1
        The hash is not so good,because when every host has more than one path
        to be monitor,this will be no longer useful;But,I can fix it later,but
        not right now,I am lazy you know.
=cut
=head10
my %fs_host = (
                'zjjwcs17' => {
                                '/home' => 85,},
                'zjjwcs18' => {
                                '/home' => 85,},
                'jfrweb02' => {
                                '/home' => 85,},
                'zjjacsc3' => {
                                '/data' => 85,},
                'zjbps13'  => {
                                '/home' => 85,},
                'zjjazw01' => {
                                '/data' => 85,},
                'zjdxra01' => {
                                '/app'  => 85,},
                'jfzknew01' => {
                                '/home' => 87,},
                'zjsawt01' => {
				'/app1' => 85,
                                '/home' => 85,},
		'zjsawt02' => {
				'/app1' => 85,
				'/home' => 85,},
		'zjjwvg01' => { 
				'/weblogic' => 85,},
		'zjjwvg02' => {
				'/weblogic' => 85,},
		'zjndem07' => {
				'/u01' => 85,},
		'zjjmzw04' => {
				'/app' => 85,},
		'zjdmzw04' => {
				'/app' => 85,},
		'zjdmzw01' => {
				'/app' => 85,
				'/home' => 85,},
		'jfrdrpt03' => {
				'/data01/aichnl1' => 85,},
		'zjddkt01' => {
				'/u02' => 85,},
		'jfzknew02' => {
				'/home/zjmarket' => 85,
				'/u01' => 85,},
		'zjdwcs04' => {
				'/home' => 85,},
		'zjdxweb05' => {
				'/home' => 85,},
		'pc-zjdwcrm29' => {
				'/' => 90,},
		'pc-zjdwcrm30' => {
				'/' => 90,},
		'pc-zjjwcrm29' => {
				'/' => 90,},
		'pc-zjjwcrm30' => {
				'/' => 90,},
		'pc-zjjwcrm14' => {
				'/' => 90,},
		'pc-zjdwcrm13' => {
				'/' => 90,},
		'pc-zjjwcrm13' => {
				'/' => 90,},
		'zjgroup1' => {
				'/opt' => 85,},
		'pc-zjdwcrm14' => {
				'/' => 90,},
		'zjdxweb03' => {
				'/home' => 85,},
		'zjsawt03' => {
				'/home' => 85,
				'/app1' => 85,},
		'zjdxra02' => {
				'/app' => 85,},
		'zjsazw01' => {
				'/data' => 90,},
		'zjdwcbs01' => {
				'/app' => 75,},
		'zjja4a01' => {
				'/was' => 85,},
		'zjdwcs02' => {
				'/home' => 85,},
		'zjsaht02' => {
				'/webapp' => 85,},
		'zjdacsc2' => {
				'/data' => 85,
				'/app' => 85,},
		'oadapt01' => {
				'/ibmapp' => 70,},
		'zjdxweb07' => {
				'/home' => 85,},
		'zjdxweb04' => {
				'/home' => 85,},
		'zjsaht01' => {
				'/webapp' => 90,},
		'zjdxweb08' => {
				'/home' => 80,},
		'zjjavg07' => {
				'/weblogic' => 85,},
		'gwjwcs01' => {
				'/weblogic' => 80,},
		'zjjdcb23' => {
				'/u01' => 85,},
		'zjdxweb06' => {
				'/home' => 85,},
);
=cut

$SIG{ALRM} = \&alarm_action;

&scan_fs(\%fs_host);
=head2
        $$$$$$$$$$$$$$$$$$$$$$OK,FUNCTION DEFINED HERE!$$$$$$$$$$$$$$$$$$$$$$
=cut

sub scan_fs($) {
        my $rh = shift;
        for my $host (sort keys %$rh) {
                my $os = $ra->{server}->{$host}->{osname};
                my $rf = $rh->{$host};
                for my $dir (keys %$rf) {
                        my $limit = $rf->{$dir};
                        if ($os eq 'HP-UX') {
				my $cmd    = "bdf $dir | tail -1";
				my $result = &auto_ssh($host,$cmd);
				if (defined $result) {
                                	my @temp  = split /\s+/,$result;
                                	my $num   = $1 if $temp[4] =~ /(\d+)\%/;
                                	if ($num >= $limit) {
                                        	&send_xml_par($host,$dir);
                                	}
                                	else {
                                        	next;
                                	}
				}
				else {
					STDERR->print("$host: SSH FAILED! or Sth Other Wrong >>> $@\n");
					next;
				}

                        } elsif ($os eq 'AIX') {
				my $cmd    = "df -k $dir | tail -1";
				my $result = &auto_ssh($host,$cmd);
				if (defined $result) {
                                	my @temp  = split /\s+/,$result;
                                	my $num   = $1 if $temp[3] =~ /(\d+)\%/;
                                	if ($num >= $limit) {
                                        	&send_xml_par($host,$dir);
                                	}
                                	else {
                                        	next;
                                	}
				}
				else {
					STDERR->print("$host: SSH FAILED! or Sth Other Wrong >>> $@\n");
					next;
				}
                        }	
                        else {
				my $cmd    = "df -k $dir | tail -1";
				my $result = &auto_ssh($host,$cmd);
				if (defined $result) {
                                	my @temp  = split /\s+/,$result;
                                	my $num   = $1 if $temp[4] =~ /(\d+)\%/;
                                	if ($num >= $limit) {
                                        	&send_xml_par($host,$dir);
                                	}
                                	else {
                                        	next;
                                	}
				}
				else {
					STDERR->print("$host: SSH FAILED! or Sth Other Wrong >>> $@\n");
					next;
				}
                        }
                }
        }
}




=head3
        In fact,it is not real send the argument to the remote host,but calling the remote script
        to use local argument,so,thanks to great SSH.
=cut
sub send_xml_par($) {
        my ($host,$dir) = (shift,shift);
        select $fh;
        my @type        = qw/file/;
        my $path_hash   = $ra->{server}->{$host}->{dirname}->{$dir}->{file_path};
        print "On $host directory $dir: \n";
        print "These Files Will be Deleted!\n";
        for my $path (sort keys %$path_hash) {
                for my $file (@{$path_hash->{$path}->{'file'}}) {
                        my $logtype  = $path_hash->{$path}->{type};
                        my $skel     = "ssh $host 'perl /ada/auto_fs_save_clean.pl $path $file $logtype'";
                        my $status   = system($skel);
                        my $time_now = "$time[1] $time[2] $time[3]";
                        print "$time_now: Sending Successfully! File $file on $host Must Be Deleted!\n"
			  if $status == 0;
                }
        }
        select STDOUT;
}

sub alarm_action {
	die 1;
}

sub auto_ssh() {
	my ($host,$cmd) = (shift,shift);
	my $action      = "ssh -o ConnectTimeout=10 $host $cmd";
	eval {
		my $status = alarm 15;
		my $result = `$action`;
		if ($status == 1) {
			die 1;
		}
		else {
			return $result;
		}
		alarm 0;
	};
}

close $fh;
