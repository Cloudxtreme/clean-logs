#!/usr/bin/perl
# Copyright (c) 2011-09-26 Ada <perl01@live.cn>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Documentation (at end) improved 2011 by Ada <perl01@live.cn>.

use strict;
use warnings;
=head1
        You should give the porgram three agruments
        or It will cause syntax error!
=cut
die "Opps! Parmernent Syntax Error!\n"
        unless @ARGV == 3;
=head2
        Here is the log file where report the running status
        of the program,so when finish runnig the progam,please
        check the log file.
=cut
my $logfile = "/ada/script.log";
open my $fh,">>","$logfile" or die "Can't Write to Log File: $!\n";

my %mons = ( 'Jan' => '01',
             'Feb' => '02',
             'Mar' => '03',
             'Apr' => '04',
             'May' => '05',
             'Jun' => '06',
             'Jul' => '07',
             'Aug' => '08',
             'Sep' => '09',
             'Oct' => '10',
             'Nov' => '11',
             'Dec' => '12',
);

my ($dir,$file_regex,$type) = (shift @ARGV,shift @ARGV,shift @ARGV);
chdir "$dir" or die "Can't Change to Target Path: $!\n";
opendir my $dh,"$dir" or die "Can't open target Dir: $!\n";

my @time = split /\s+/,localtime();

if ($type eq "number") {
        &num_fs_clean(\$dh);
} elsif ($type eq "time") {
        my @all_files = <$file_regex*>;
        my $mon = $mons{$time[1]};
        my ($year,$days) = ($time[4],$time[2]);
        my @want = ($time[2]-1,$time[2]-2,$time[2]-3,$time[2]-4,$time[2]-5,$time[2]-6,$time[2]-7);
        my $num = substr($year,2,2);
        for my $day (sort @want) {
                my $regex = $file_regex . "(\.|\_|\-)($year|$num)(\-)?$mon(\-)?(0)?$day(\.log|)";
                &fs_clean(\@all_files,$regex);
        }
} elsif ($type eq "spec") {
        &spec_fs_clean(\$dh);
} elsif ($type eq "db") {
        my $regex1 = $file_regex . "(\_)?(.*)(\.trc)";
        &db_fs_clean(\$dh,$regex1);
}

sub fs_clean($$) {
        select $fh;
        my ($ra, $regex) = (shift, shift);
        for my $file (@$ra) {
                next unless -T $file;
                if ($file =~ qr/$regex/) {
                        my $skel = "cat /dev/null >$file";
                        my @action = system($skel);
                        my $now = "$time[1] $time[2] $time[3]";
                        print "$now : $file Successfully Be Cleaned!\n"
                                        if pop @action == 0;
                }

        }
        select STDOUT;
}

sub num_fs_clean($) {
        select $fh;
        my $ra = shift;
        while (my $file = readdir $$ra) {
                next unless -T $file and -M $file > 2;
                if ($file =~ /$file_regex(\.)?(\_)?(\d)+(\S+)?(\.log)?/) {
                        my $now = "$time[1] $time[2] $time[3]";
                        my $suc = unlink $file;
                        print "$now : $file is be deleted!\n" if defined $suc;
                }
        }
        select STDOUT;
}

sub spec_fs_clean($) {
        select $fh;
        my $ra = shift;
        my $file = $file_regex;
        my $skel = "tail -1000 $file > $file";
        my @action = system($skel);
        my $now = "$time[1] $time[2] $time[3]";
        print "$now : $file Successfully Be Cleaned!\n"
                                if pop @action == 0;
        select STDOUT;
}

sub db_fs_clean($$) {
        select $fh;
        my ($ra, $regex) = (shift, shift);
        while (my $file = readdir $$ra) {
                next unless -T $file and -M $file > 2;
                if ($file =~ qr/$regex/) {
                        my $now = "$time[1] $time[2] $time[3]";
                        my $suc = unlink $file;
                        print "$now : $file is be deleted!\n" if defined $suc;
                }
        }
        select STDOUT;
}
&normal_clean();
sub normal_clean() {
        my $dir = "/var/adm";
        my @files = <$dir/wtmp* $dir/btmp*>;
        for (@files) {
                my $skel = "cat /dev/null >$_";
                system($skel);
        }
}
close $fh;
close $dh;
