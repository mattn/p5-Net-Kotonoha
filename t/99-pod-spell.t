use strict;
use t::TestKotonoha;

BEGIN {
    test_requires('Test::Spelling');
}

use FindBin;
use Test::Spelling;

my $spell_cmd;
foreach my $path (split(/:/, $ENV{PATH})) {
    -x "$path/spell"  and $spell_cmd="spell", last;
    -x "$path/ispell" and $spell_cmd="ispell -l", last;
    -x "$path/aspell" and $spell_cmd="aspell list", last;
}
$ENV{SPELL_CMD} and $spell_cmd = $ENV{SPELL_CMD};
$spell_cmd or plan skip_all => "no spell/ispell/aspell";
set_spell_cmd($spell_cmd);

add_authors_to_stopwords();
add_stopwords(<DATA>);
all_pod_files_spelling_ok('lib');

sub add_authors_to_stopwords {
    my $file = "$FindBin::Bin/../AUTHORS";
    open my $fh, "<", $file or die "$file: $!";
    while (<$fh>) {
        chomp;
        tr/\(\)//d;
        add_stopwords(split /\s+/);
    }
}

__DATA__
API
AdSense
Anil
AppleScript
AtomPP
AutoLink
Babelfish
BalloonNotify
Blog
BlogPet
BlogPet's
Bloglines
Bulkfeeds
Buzzurl
CDTF
CONFIGS
CPAN
CSV
CVS
ControlPort
DWIM
DWIMs
DateTime
Deduped
Emoticon
EntryFullText
Estraier
FLV
FOAF
FULLTEXT
FeedBurner
FeedBurner's
FeedFlare
Filename
Firefox
Flickr
Fotolife
Frepa
FriendDiary
Gmail
GoogleTalk
Gungho
HTML
HTTP
Hatena
HatenaDiary
HatenaGroup
HatenaRSS
IDs
IE
IKC
IMAP
IP
InternetExplorer
JS
JSON
JSONP
KinoSearch
koto
kotonoha
Kotonoha
Langworth's
Lilypond
Lingr
Livedoor
Lucene
MSN
MSWin
MacOSX
Maildir
MeDoc
Mixi
Moritapo
MozRepl
MyDiary
NFC
NFD
NFKC
NFKD
Namaan
Namazu
NetNewsWire
Newsoku
Newsokuize
Nihongo
OPML
OSX
Odeo
PDF
POPFile
POSIX
PSP
PalmDoc
Plagger
Pluggable
PowerPoint
RDF
RFC
RPC
RSS
Rast
RecentComment
SCREENSHOT
SQL
SSH
SSTP
STDOUT
SVN
Serializer
SmartFeed
SpamAssassin's
Splog
TODO
TZ
Tiarra
Trackback
Trott
UA
URI
URL
URLBL
URLs
UTC
Wiki
XHTML
XML
XMLRPC
XOXO
XPath
XXX
YAML
YahooBlogSearch
YouTube
aggregator
aggregators
al
ala
apihost
apirealm
apiurl
asahi
ascii
atomfeed
authen
autodiscovery
backend
ben
blog
blog's
blogroll
blogs
blosxom
bookmarked
bot
brian
callback
cc
ccTLD
ch
chRSSPermalink
co
com
conf
cronjob
csv
darwin
datetime
de
deduplicate
del
delimited
dir
embeddable
emoticons
en
euc
exe
extendedPing
fallbacks
feedburner's
filename
foaf
foafroll
foo
foobar
formatter
foy
freebsd
freenode
fulltext
gif
google
guid
hackish
hatena
href
html
iCal
iPhoto
iPod
iTunes
icio
ics
ini
init
inline
ip
irc
ircbot
ized
ja
javascript
jp
json
jsonp
lang
lastBuildDate
linux
listsubs
livedoor
livedoorClip
login
mailfrom
mailroute
mailto
medoc
metadata
microformats
mixi
mp
namespace
perlbal
permalink
permalinks
photocast
pingserver
pipermail
plagger
plagger's
plaggerbot
plaintext
playlog
pluggable
plugins
pm
pubDate
qpsmtpd
quickstart
rdf
rebless
referer
remixer
rsd
rss
rssad
san
searchable
serializer
shiftjis
sixapart
smartfeeds
smtp
src
std
strptime
stylesheet
svn
swf
tDiary
tagline
takahashi
technorati
templatize
thingy
timezones
unsubscribe
url
urls
username
utf
varname
webbookmark
weblogUpdates
wget
win32
wosit
www
xml
xul
yaml
