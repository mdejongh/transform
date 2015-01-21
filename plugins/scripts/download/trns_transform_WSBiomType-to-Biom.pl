#!/usr/bin/env perl

use strict;

use Getopt::Long::Descriptive;
use Bio::KBase::workspace::Client;

my($opt, $usage) = describe_options("%c %o",
				    ['workspace_service_url=s', 'workspace service url to retrieve workspace object from', { required => 1 } ],
				    ['workspace_name=s', 'workspace name from which the workspace object is to be retrieved', { required => 1 } ],
				    ['object_name=s', 'workspace object name to retrieve', { required => 1 } ],
				    ['output_file_name=s', 'path to where output should be saved', { required => 1 } ],
				    ['object_version=i', 'version of workspace object to retrieve (default => most recent)' ],
				    ['help|h', 'show this help message'],
				    );

if ($opt->help) {
    print $usage->text;
    exit;
}

my $wsclient = Bio::KBase::workspace::Client->new($opt->workspace_service_url);
my $ret;
if ($opt->object_version) {
    $ret = $wsclient->get_object({ id => $opt->object_name, workspace => $opt->workspace_name, instance => $opt->object_version });
} else {
    $ret = $wsclient->get_object({ id => $opt->object_name, workspace => $opt->workspace_name });
}

if ($ret->{data}) {
    my $biom = $ret->{data};
    my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
    open OUT, ">".$opt->output_file_name || die "Cannot print WS biom object to file: ".$opt->output_file_name."\n";
    print OUT $coder->encode ($biom);
    close OUT;
} else {
    if ($opt->object_version) {
        die "Invalid return from get_object for id=".$opt->object_name." workspace=".$opt->workspace_name." instance=".$opt->object_version."\n";
    } else {
        die "Invalid return from get_object for id=".$opt->object_name." workspace=".$opt->workspace_name."\n";
    }
}
