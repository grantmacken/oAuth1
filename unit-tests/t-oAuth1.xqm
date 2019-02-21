xquery version '3.1';
(:~
This module contains XQSuite tests for library http://markup.nz/#oAuth1
declare variable vars are derived from
@see https://dev.twitter.com/oauth/overview/authorizing-requests
@see https://dev.twitter.com/oauth/overview/creating-signatures
 URLs below are placed in a map for testing
:)
module namespace t-oAuth1 = "http://markup.nz/#t-oAuth1";
import module namespace oAuth1 = "http://markup.nz/#oAuth1";
import module namespace test = "http://exist-db.org/xquery/xqsuite"
  at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

(:~
vars derived from URLs below are placed in a map for testing
@see https://dev.twitter.com/oauth/overview/authorizing-requests
@see https://dev.twitter.com/oauth/overview/creating-signatures
:)
declare variable $t-oAuth1:map :=  map {
    'method' : 'post',
    'resource_URL' : 'https://api.twitter.com/1/statuses/update.json',
    'status' : 'Hello Ladies + Gentlemen, a signed OAuth request!',
    'include_entities' : 'true',
    'oauth_consumer_key' : 'xvz1evFS4wEEPTGEFPHBog',
    'oauth_consumer_secret' : 'kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw',
    'oauth_nonce' : 'kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg',
    'oauth_signature_method' : 'HMAC-SHA1',
    'oauth_timestamp' : '1318622958',
    'oauth_token' : '370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb',
    'oauth_token_secret' : 'LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE',
    'oauth_version' : '1.0'
    };

(:~
creates a url encoded *signature base* string
@given args 'post' and  url 
@when creating a signature
@then the correct url encoded string should be produced
@see https://dev.twitter.com/oauth/overview/creating-signatures
@param $arg1  method
@param $arg2  url
:)
declare
%test:name(
'should create a url encoded *signature base* string'
)
%test:args(
  'post',
  'https://api.twitter.com/1/statuses/update.json'
)
%test:assertEquals(
'POST&amp;https%3A%2F%2Fapi.twitter.com%2F1%2Fstatuses%2Fupdate.json&amp;include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521'
)
function t-oAuth1:createSignatureBaseString( $arg1 as xs:string , $arg2 as xs:string) as xs:string {
oAuth1:createSignatureBaseString(
$arg1,
$arg2,
 oAuth1:createParameterString(
  map {
    'status' : $t-oAuth1:map('status'),
    'include_entities' : $t-oAuth1:map('include_entities'),
    'oauth_consumer_key' :  $t-oAuth1:map('oauth_consumer_key'),
    'oauth_nonce' : $t-oAuth1:map('oauth_nonce'),
    'oauth_signature_method' : $t-oAuth1:map('oauth_signature_method'),
    'oauth_timestamp' : $t-oAuth1:map('oauth_timestamp'),
    'oauth_token' : $t-oAuth1:map('oauth_token'),
    'oauth_version' : $t-oAuth1:map('oauth_version')
    }
  )
)
};

(:~
creates a percent encoded *Signing Key*
@given args 'Consumer secret' and 'OAuth token secret' 
@when creating a signing key
@then the correct a percent encoded string should be produced
@see https://dev.twitter.com/oauth/overview/creating-signatures
@param $arg1 Consumer secret
@param $arg2 OAuth token secret
:)
declare
%test:name('should create a percent encoded *Signing Key*')
%test:args(
  'kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw',
  'LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE'
  )
%test:assertEquals('kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw&amp;LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE')
function t-oAuth1:createSigningKey( $arg1 as xs:string , $arg2 as xs:string) as xs:string {
oAuth1:createSigningKey( $arg1 , $arg2 )
};

(:~
create a *parameter string* that is percent encoded
@given a map as map() with correct key values
@when calling 'createParameterString'to create a parameter string
@then the correct a percent encoded string should be produced
@see the https://dev.twitter.com/oauth/overview/creating-signatures
:)
declare
%test:name(
'should create a *parameter string* that is percent encoded'
)
%test:assertEquals(
'include_entities=true&amp;oauth_consumer_key=xvz1evFS4wEEPTGEFPHBog&amp;oauth_nonce=kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg&amp;oauth_signature_method=HMAC-SHA1&amp;oauth_timestamp=1318622958&amp;oauth_token=370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb&amp;oauth_version=1.0&amp;status=Hello%20Ladies%20%2B%20Gentlemen%2C%20a%20signed%20OAuth%20request%21'
)
function t-oAuth1:createParameterString() as xs:string {
 oAuth1:createParameterString(
  map {
    'status' : $t-oAuth1:map('status'),
    'include_entities' : $t-oAuth1:map('include_entities'),
    'oauth_consumer_key' :  $t-oAuth1:map('oauth_consumer_key'),
    'oauth_nonce' : $t-oAuth1:map('oauth_nonce'),
    'oauth_signature_method' : $t-oAuth1:map('oauth_signature_method'),
    'oauth_timestamp' : $t-oAuth1:map('oauth_timestamp'),
    'oauth_token' : $t-oAuth1:map('oauth_token'),
    'oauth_version' : $t-oAuth1:map('oauth_version')
    }
  )
};

(:~
@given 4 args and the param map 
@when calling 'calculateSignature'
@then the correct base64 encoded string should be produced
@param $arg1 Consumer secret
@param $arg2 OAuth token secret
:)
declare
%test:name(
'should calculate the signature as a base64 encoded string'
)
%test:args(
  'post',
  'https://api.twitter.com/1/statuses/update.json',
  'kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw',
  'LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE'
  )
%test:assertEquals('tnnArxj06cWHq44gCs1OSKk/jLY=')
function t-oAuth1:calculateSignature(
  $arg1 as xs:string,
  $arg2 as xs:string,
  $arg3 as xs:string,
  $arg4 as xs:string
  ) as xs:string {
oAuth1:calculateSignature(
  oAuth1:createSignatureBaseString(
  $arg1,
  $arg2,
  oAuth1:createParameterString(
    map {
      'status' : $t-oAuth1:map('status'),
      'include_entities' : $t-oAuth1:map('include_entities'),
      'oauth_consumer_key' :  $t-oAuth1:map('oauth_consumer_key'),
      'oauth_nonce' : $t-oAuth1:map('oauth_nonce'),
      'oauth_signature_method' : $t-oAuth1:map('oauth_signature_method'),
      'oauth_timestamp' : $t-oAuth1:map('oauth_timestamp'),
      'oauth_token' : $t-oAuth1:map('oauth_token'),
      'oauth_version' : $t-oAuth1:map('oauth_version')
      }
    )
  ),
  oAuth1:createSigningKey( $arg3, $arg4 )
 )
};



(:~
This is the only on to use
@given 4 args and the param map 
@when calling 'buildHeaderString'
@then the correct header string should be produced
@https://dev.twitter.com/oauth/overview/creating-signatures
@param $arg1 method
@param $arg2 URL
@param $arg3 Consumer secret
@param $arg4 OAuth token secret
:)
declare
%test:name(
'should create oAuth1 header string that can be used to tweet'
)
%test:args(
  'post',
  'https://api.twitter.com/1/statuses/update.json',
  'kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw',
  'LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE'
  )
%test:assertEquals(
'OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog", oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg", oauth_signature="tnnArxj06cWHq44gCs1OSKk%2FjLY%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1318622958", oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb", oauth_version="1.0"'
)
function t-oAuth1:buildHeaderString(
  $arg1 as xs:string,
  $arg2 as xs:string,
  $arg3 as xs:string,
  $arg4 as xs:string
  ) as xs:string {

let $oauthSignature := oAuth1:calculateSignature(
  oAuth1:createSignatureBaseString(
  $arg1,
  $arg2,
  oAuth1:createParameterString(
    map {
      'status' : $t-oAuth1:map('status'),
      'include_entities' : $t-oAuth1:map('include_entities'),
      'oauth_consumer_key' :  $t-oAuth1:map('oauth_consumer_key'),
      'oauth_nonce' : $t-oAuth1:map('oauth_nonce'),
      'oauth_signature_method' : $t-oAuth1:map('oauth_signature_method'),
      'oauth_timestamp' : $t-oAuth1:map('oauth_timestamp'),
      'oauth_token' : $t-oAuth1:map('oauth_token'),
      'oauth_version' : $t-oAuth1:map('oauth_version')
      }
    )
  ),
  oAuth1:createSigningKey( $arg3, $arg4 )
 )

return
oAuth1:buildHeaderString(
 map {
  'oauth_consumer_key' : $t-oAuth1:map('oauth_consumer_key'),
  'oauth_nonce' :  $t-oAuth1:map('oauth_nonce'),
  'oauth_signature' : $oauthSignature,
  'oauth_signature_method' : $t-oAuth1:map('oauth_signature_method'),
  'oauth_timestamp' : $t-oAuth1:map('oauth_timestamp'),
  'oauth_token' : $t-oAuth1:map('oauth_token'),
  'oauth_version' : $t-oAuth1:map('oauth_version')
  }
)
};
