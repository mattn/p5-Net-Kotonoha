package Net::Kotonoha::Koto;

use strict;

use warnings;
use URI;
use HTML::Selector::XPath qw/selector_to_xpath/;
use HTML::TreeBuilder::XPath;
use Encode;

sub new {
    my $class = shift;
    my %args = @_;
    $args{content} = '';
    return bless {%args}, $class;
}

sub _get_content {
    my $self = shift;
    my $koto_no = $self->{koto_no};
	my $limit = $self->{kotonoha}->{limit};
    return unless defined $self->{kotonoha}->{loggedin};
    unless ($self->{content}) {
        my $res = $self->{kotonoha}->{mech}->get("http://kotonoha.cc/no/$koto_no?limit=$limit");
        if ($res->is_success) {
            $self->{content} = $res->content;
        }
    }
    return $self->{content};
}

sub _get_list {
    my $self = shift;
    my $xpath = shift;
    my $answer = shift || '';

    my @list;
    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse( $self->_get_content );
    $tree->eof;
    foreach my $item ($tree->findnodes($xpath)) {
        my $user = $item->findnodes(('.//div[@class="userbox"]//a'))->shift;
        my $comment = $item->findnodes(('.//p[@class="comment"]'));
        my $link = $user->attr('href');
        if ($link =~ /^\/user\/(\w+)/) {
            push @list, {
                user => $1,
                name => $user->attr('title'), 
                comment => $comment ? $comment->shift->as_text : '',
                answer => $answer,
            }
        }
    }

    foreach my $item ($tree->findnodes('//dl[@id="answeredusers"]//div[@class="userbox"]')) {
        my $user = $item->findnodes(('.//a'))->shift;
        my $comment = $item->findnodes(('.//p'))->shift->as_text;
        my $link = $user->attr('href');
        if ($link =~ /^\/user\/(\w+)/) {
            my $userid = $1;
            if (!grep($_->{user} eq $userid, @list)) {
                push @list, {
                    user => $userid,
                    name => $user->attr('title'), 
                    comment => '',
                    answer => $comment =~ '\xe2\x97\x8b' ? 1 : 2,
                }
            }
        }
    }
    $tree->delete;
    return @list;
}

sub yesman {
    return shift->_get_list('//dl[@id="commentsyes"]//ul[@class="commentbox"]', 1);
}

sub noman {
    return shift->_get_list('//dl[@id="commentsno"]//ul[@class="commentbox"]', 2);
}

sub title {
    my $self = shift;
    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse( $self->_get_content );
    $tree->eof;
    my $t = $tree->findnodes('//title');
    $t = $t ? $t->shift->as_text : undef;
    $tree->delete;
    $t;
}

sub answer {
    my $self = shift;
    if (@_) {
        my $my_answer = shift;
        my $my_comment = shift;
        my $uri = URI->new('http://kotonoha.cc/');
        $uri->query_form(
            mode    => 'ajax',
            act     => 'set_done_flag',
            koto_id => $self->{koto_no},
            flag    => $my_answer,
        );
        my $res = $self->{kotonoha}->{mech}->get($uri->as_string);
        if ($res->is_success && $res->content) {
            # need to reset
            $self->{content} = '';

            if ($my_comment) {
                $uri = URI->new('http://kotonoha.cc/');
                $uri->query_form(
                    mode    => 'ajax',
                    act     => 'post_comment',
                    koto_id => $self->{koto_no},
                    comment => Encode::encode_utf8($my_comment),
                );
                my $res = $self->{kotonoha}->{mech}->get($uri->as_string);
            }
            return 1;
        }
    } else {
        my @found;
        my $myself = $self->{kotonoha}->{user};
        @found = grep $_->{user} eq $myself, $self->yesman;
        @found = grep $_->{user} eq $myself, $self->noman unless @found;
        return shift @found;
    }
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

=head1 COPYRIGHT

Copyright (c) 2007 Yasuhiro Matsumoto.  All rights reserved.  This program
is free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

L<Net::Kotonoha>

=cut
