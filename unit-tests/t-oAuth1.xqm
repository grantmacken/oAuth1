xquery version '3.1';
(:~
This module contains XQSuite tests for library
http://markup.nz/#oAuth1
:)
module namespace t-oAuth1 = "http://markup.nz/#t-oAuth1";
import module namespace oAuth1 = "http://markup.nz/#oAuth1";
import module namespace test = "http://exist-db.org/xquery/xqsuite"
  at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

(:~
oAuth1:example
@Given arg 'Grant' as xs:string
@When function example function is called
@Then 'Hi Grant' is the correct response
:)
declare
%test:name(
"
should say 'Hi Grant"
)
%test:args('Grant')
%test:assertEquals('Hi Grant')
function t-oAuth1:example($arg){
$arg => oAuth1:example()
};
