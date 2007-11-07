package Net::Kotonoha;

use strict;
use warnings;
use 5.8.1;
use WWW::Mechanize;
use HTML::Selector::XPath qw/selector_to_xpath/;
use HTML::TreeBuilder::XPath;
use Data::Dumper;
use Net::Kotonoha::Koto;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my %args  = @_;

    $args{mail}     ||= '';
    $args{password} ||= '';
    $args{user}     ||= '';
    $args{limit}    ||= 1000;

    my $mech = WWW::Mechanize->new;
    $mech->agent_alias('Windows IE 6');
	$mech->quiet(1);
    $mech->add_header('Accept-Encoding', 'identity');
    $args{mech} = $mech;

    return bless {%args}, $class;
}

sub login {
    my $self = shift;

	return 1 if $self->{loggedin};

    $self->{mech}->get('http://kotonoha.cc');
    my $res = $self->{mech}->submit_form(
        form_number => 1,
        fields      => {
            mail     => $self->{mail},
            password => $self->{password},
        }
    );
	if  ($res->is_success && $self->{mech}->uri =~ /\/home$/) {
		my $tree = HTML::TreeBuilder::XPath->new;
		$tree->parse($res->content);
		$tree->eof;
		my $user = $tree->findnodes(selector_to_xpath('dt.profileicon a'));
		my $link = $user ? $user->shift->attr('href') : '';
		if ($link =~ /^\/user\/(\w+)/) {
			$self->{loggedin} = ($self->{user} = $1);
		}
	}
	return $self->{loggedin};
}

sub _get_list {
    my $self = shift;
    my $xpath = shift;

	$self->login unless defined $self->{loggedin};

    my $res = $self->{mech}->get('http://kotonoha.cc/home');
	return unless $res->is_success;

	my @list;

	my $tree = HTML::TreeBuilder::XPath->new;
	$tree->parse($res->content);
	$tree->eof;
	foreach my $item ($tree->findnodes(selector_to_xpath($xpath))) {
		if ($item->attr('href') =~ /^\/no\/(\d+)/) {
			my $koto_no = $1;
			if ($item->as_text =~ /^(.*)\s*\(([^\)]+)\)$/) {
				push @list, {
					koto_no => $koto_no,
					title   => $1,
					answers => $2
				}
			}
		}
	}
	$tree->delete;
	return @list;
}

sub newer_list {
	return shift->_get_list('dl#newkoto a');
}

sub recent_list {
	return shift->_get_list('dl#recentkoto a');
}

sub get_koto {
    my $self = shift;
	$self->login unless defined $self->{loggedin};
	return Net::Kotonoha::Koto->new(
		kotonoha => $self,
		koto_no => shift);
}

1;
__END__

=head1 NAME

Net::Kotonoha - A perl interface to kotonoha.cc

=head1 SYNOPSIS

  use Net::Kotonoha;
  use Data::Dumper;

  my $kotonoha = Net::Kotonoha->new(
        mail     => 'xxxxx@example.com',
        password => 'xxxxx',
    );
  print Dumper $kotonoha->newer_list;
  my $koto = $kotonoha->get_koto(120235);
  $koto->answer(1, 'YES!YES!YES!');
  print Dumper $koto->answer;

=head1 DESCRIPTION

This module allows easy access to kotonoha. kotonoha is not provide API.
Thus, this module is helpful for make kotonoha application.

=head1 AUTHOR

Yasuhiro Matsumoto E<lt>mattn.jp@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<WWW::Mechanize>

=cut
