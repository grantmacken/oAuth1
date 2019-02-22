xquery version "3.1";
module namespace oAuth1  = "http://markup.nz/#oAuth1";
import module namespace crypto =  "http://expath.org/ns/crypto";
(:~
: The <b>oAuth1</b> library provides functions ...
:)

declare
function oAuth1:example() as xs:string {
  (
   ' - oAuth1:authorizationHeader#2 can be used to create an "authorization header" ', 
   ' - that can be used to make a Twitter API requests ',
   ' - vars used in example come from twitter API docs',
   ' - 2 maps are passed to oAuth1:authorizationHeader#2 ',
   ' - this results in a authorization header string ... ',
   ( 
   map {
    'method' : 'POST',
    'resource' : 'https://api.twitter.com/1.1/statuses/update',
    'oauth_consumer_key' : 'xvz1evFS4wEEPTGEFPHBog',
    'oauth_consumer_secret' : 'kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw',
    'oauth_token_secret' : '370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb',
    'oauth_token' : 'LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE'
    }
   ) =>  
    oAuth1:authorizationHeader(
    map { 'status' : 'Hello Ladies + Gentlemen, a signed OAuth request!' }
    )
) => string-join('&#10;')
};

(:~
creates an *'authorization header'* that can be used to make a Twitter API requests
This is main function, the only one you need
@param $map  key, value map of a twitter authorisation credentials plus method and API resource
@param $qMap key, value map of a URL query params
@return string repesenting a oAuth header value
:)
declare
function oAuth1:authorizationHeader( $map as map(*), $qMap as map(*) ) as xs:string {
 try {
  (: let $log1 := util:log-system-out( ' - create authorization header ' ) :)
  let $timeStamp := oAuth1:createTimeStamp()
  let $nonce := oAuth1:createNonce()
  let $params := map:merge((
 $qMap,
  map {
    'oauth_consumer_key' :  $map('oauth_consumer_key'),
    'oauth_nonce' : $nonce,
    'oauth_signature_method' : 'HMAC-SHA1',
    'oauth_timestamp' : $timeStamp,
    'oauth_token' : $map('oauth_token'),
    'oauth_version' : '1.0'
    }))

  let $resource := xmldb:decode-uri($map('resource'))
  let $oAuthSignature :=
      oAuth1:calculateSignature(
      oAuth1:createSignatureBaseString(
        $map('method'),
        $resource,
        oAuth1:createParameterString( $params )
      ),
      oAuth1:createSigningKey(
      $map('oauth_consumer_secret'),
      $map('oauth_token_secret'))
  )
  let $headerMap :=
      map {
        'oauth_consumer_key' : $map('oauth_consumer_key'),
        'oauth_nonce' :  $params('oauth_nonce'),
        'oauth_signature' : $oAuthSignature ,
        'oauth_signature_method' : $params('oauth_signature_method'),
        'oauth_timestamp' : $params('oauth_timestamp'),
        'oauth_token' : $map('oauth_token'),
        'oauth_version' : $params('oauth_version')
        }
      return (
        oAuth1:buildHeaderString( $headerMap )
      )
    }
    catch *{
      util:log-system-out( 'ERROR: ' ||   $err:line-number || ':' || $err:description )
      }
};

(:~
concats the header items into one long header string
in section 'Building the header string' in doc below 
@see https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request
@see https://dev.twitter.com/oauth/overview/authorizing-requests
@param $map map of params
@return string oAuth header value
:)
declare
function oAuth1:buildHeaderString(
  $map as map(*) ) as xs:string {
concat(
    'OAuth oauth_consumer_key="',
    encode-for-uri( $map('oauth_consumer_key')),
    '", oauth_nonce="',
    encode-for-uri( $map('oauth_nonce')),
    '", oauth_signature="',
     encode-for-uri($map('oauth_signature')),
    '", oauth_signature_method="',
    encode-for-uri( $map('oauth_signature_method')),
    '", oauth_timestamp="',
    encode-for-uri( $map('oauth_timestamp')),
    '", oauth_token="',
    encode-for-uri( $map('oauth_token')),
    '", oauth_version="',
    encode-for-uri( $map('oauth_version')),
    '"')
};

(:~
collect Parameters included in request
in section Collecting parameters in 
@see https://developer.twitter.com/en/docs/basics/authentication/guides/creating-a-signature.html
@param $params map of params
@return string 
:)
declare function oAuth1:createParameterString(
$params as map(*) ) as xs:string {
  string-join(
  (
  for $item in (
    map:for-each( $params,
      function( $key, $value ) {
        concat(
        encode-for-uri( $key ),
        '=',
        encode-for-uri( $value )
        )
        }
      ))
   order by $item
    return
    $item
  ),
      '&amp;'
    )
};

(: TODO! above use sort after eXist implements sort :)

(:~
create the *Signature Base String*
@see https://dev.twitter.com/oauth/overview/creating-signatures
To encode the HTTP method, base URL, and parameter string into a single string:
 - Convert the HTTP Method to uppercase and set the output string equal to this value.
 - Append the ‘&’ character to the output string.
 - Percent encode the URL and append it to the output string.
 - Append the ‘&’ character to the output string.
 - Percent encode the parameter string and append it to the output string
@see modules/tests/lib/oAuth.xqm;t-oAuth1:createSignatureBaseString
@param $method  as xs:string,
@return string  a percent encoded string
:)
declare function oAuth1:createSignatureBaseString(
$method as xs:string,
$baseUrl as xs:string,
$parameterString as xs:string
) as xs:string {
  string-join((
    upper-case( $method ) ,
    encode-for-uri( $baseUrl ),
    encode-for-uri( $parameterString )
    ),
  '&amp;'
  )
};


(:~
create the *Signing Key* 
In section 'Getting a signing key' in doc 
@see https://developer.twitter.com/en/docs/basics/authentication/guides/creating-a-signature.html
@param $consumerSecret  Consumer secret
@param $accessTokenSecret  OAuth token secret
@return a percent encoded string
:)
declare function oAuth1:createSigningKey(
  $consumerSecret as xs:string, 
  $accessTokenSecret as xs:string
  ) as xs:string  {
string-join(
  (
  encode-for-uri( $consumerSecret ),
  encode-for-uri( $accessTokenSecret )
  ),'&amp;'
)
};

(:~
calculates the *signature* by passing signatureBaseString and signingKey and hashing with hmac
In section 'calculating the signature' in doc 
@see https://developer.twitter.com/en/docs/basics/authentication/guides/creating-a-signature.html
@param $signatureBaseString  percent encoded base string 
@param $signingKey percent encoded signing key 
@return hmac signed binary string base64 encoded
:)
declare function oAuth1:calculateSignature(
  $signatureBaseString as xs:string,
  $signingKey as xs:string
  ) as xs:string  {
crypto:hmac(
  $signatureBaseString,
  $signingKey,
  'HmacSha1',
  'base64'
)
};

declare function oAuth1:createNonce() as xs:string {
  util:uuid()
};

(:
@see https://gist.github.com/joewiz/5929809
Generates an OAuth timestamp, which takes the form of
the number of seconds since the Unix Epoch. You can test
these values against http://www.epochconverter.com/.
@see http://en.wikipedia.org/wiki/Unix_time 
:)
declare function oAuth1:createTimeStamp() as xs:unsignedLong {
    let $unix-epoch := xs:dateTime('1970-01-01T00:00:00Z')
    let $now := current-dateTime()
    let $duration-since-epoch := $now - $unix-epoch
    let $seconds-since-epoch :=
        days-from-duration($duration-since-epoch) * 86400 (: 60 * 60 * 24 :)
        +
        hours-from-duration($duration-since-epoch) * 3600 (: 60 * 60 :)
        +
        minutes-from-duration($duration-since-epoch) * 60
        +
        seconds-from-duration($duration-since-epoch)
    return
        xs:unsignedLong($seconds-since-epoch)
};



