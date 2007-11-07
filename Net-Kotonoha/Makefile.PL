use inc::Module::Install;
name 'Net-Kotonoha';
all_from 'lib/Net/Kotonoha.pm';

build_requires 'Test::More';
requires 'WWW::Mechanize' => 1.22;
requires 'HTML::Selector::XPath' => 0.02;
requires 'HTML::TreeBuilder::XPath' => 0.08;
requires 'utf8' => 1.04;

WriteAll;
