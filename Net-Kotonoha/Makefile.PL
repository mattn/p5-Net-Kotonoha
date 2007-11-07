use inc::Module::Install;
name 'Net-Kotonoha';
all_from 'lib/Net/Kotonoha.pm';

build_requires 'Test::More';
requires 'WWW::Mechanize' => 1.22;

WriteAll;
