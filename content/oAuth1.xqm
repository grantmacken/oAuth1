xquery version "3.1";
module namespace oAuth1  = "http://markup.nz/#oAuth1";
(:~
: The <b>oAuth1</b> library provides functions ...
:)

(:~
show what oAuth1 lib can do in example
:)
declare function oAuth1:example($name) as xs:string*{
(( 'Hi', $name )) => string-join(' ')
};
