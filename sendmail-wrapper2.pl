#!/usr/bin/perl

use strict;
use warnings;
use Net::SMTP;
use Email::Address;
use Email::MessageID;
use Email::Date::Format qw(email_date);
##use Net::Domain qw(hostname hostfqdn hostdomain domainname);

my $user = getpwuid( $< );
##my $server = hostdomain () || hostfqdn ()  || domainname () || 'localhost';
my $server = 'server.name';
my $input = '';
my $to_string = '';
my $from_string = '';
my $subject = '';
my $messageID = '';
my $Date = '';

my $cc_string = '';
my $bcc_string = '';

# improve here to be sure it is in headers !
# Email::Simple should do better !
foreach my $line ( <STDIN> ) {
  $input .= $line;
  if ($line =~ /^To:/i) {
    $to_string = $line;#
  }
  if ($line =~ /^From:/i) {
    $from_string = $line;
  }
  if ($line =~ /^Subject:/i) {
    $subject = $line;
  }
  if ($line =~ /^Message-Id:/i) {
    $messageID = $line;
  }

  if ($line =~ /^Cc:/i) {
    $cc_string = $line;
  }
  if ($line =~ /^Bcc:/i) {
    $bcc_string = $line;
  }
  
  if ($line =~ /^Date:/i) {
    $Date = $line;
  }
}

# add header if missing
my $mid = Email::MessageID->new->in_brackets;
$input = "Message-ID: $mid\r\n$input" unless $messageID ne '';

# add date if missing
my $dateheader = email_date(time);
$input = "Date: $dateheader\r\n$input" unless $Date ne '';

#check destination
my @addrs = Email::Address->parse($to_string);
if (0+@addrs eq 0) {
  die "No recipients";
}

for (my$index=0;$index<=$#addrs;$index++){
  my $rec = $addrs[$index];
  $rec=$rec->address;

  my @fraddrs = Email::Address->parse($from_string);
  my $frec = $user.'@'.$server;
  $frec = $fraddrs[0]->address unless (0+@fraddrs eq 0);

  my @cca = Email::Address->parse($cc_string);
  my $ccrec = '';
  $ccrec = $cca[0]->address unless (0+@cca eq 0);

  my @bcca = Email::Address->parse($bcc_string);
  my $bccrec = '';
  $bccrec = $bcca[0]->address unless (0+@bcca eq 0);

  my $smtp = Net::SMTP->new('127.0.0.1', Port => 25, Timeout => 10, Debug => 0);
  die "Could not connect to smtpd\n" unless $smtp;
  $smtp->mail($frec);
  $smtp->to($rec);
  if ($cc_string ne '') {
  $smtp->cc($ccrec);
  }
  if ($bcc_string ne '') {
  $smtp->bcc($bccrec);
  }
    $smtp->data();
  $smtp->datasend($input);
  $smtp->dataend();
  $smtp->quit;
}
