xquery version "3.1";
module namespace oAuth1  = "http://markup.nz/#oAuth1";
(:~
: The <b>oAuth1</b> library provides functions ...
:)

(:~
creates *'authorization header'* that can be used to make a Twitter API requests
@see unit-tests/lib/oAuth.xqm;t-oAuth:buildHeaderString 
@param $map  key, value map of a twitter authorisation credentials plus method and API resource
@param $qMap key, value map of a URL query params
@return string repesenting a oAuth header value
:)
declare
function oAuth:authorizationHeader( $map as map(*), $qMap as map(*) ) as xs:string {
 try {
  (: let $log1 := util:log-system-out( ' - create authorization header ' ) :)
  let $timeStamp := oAuth:createTimeStamp()
  let $nonce := oAuth:createNonce()
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
  (:
  let $log1 := util:log-system-out( 'timestamp: ' || $params('oauth_timestamp'))
  let $log2 := util:log-system-out('nonce: '  || $params('oauth_nonce') )
  let $log3 := util:log-system-out('resource: '  || $resource )
  :)
  let $oAuthSignature :=
      oAuth:calculateSignature(
      oAuth:createSignatureBaseString(
        $map('method'),
        $resource,
        oAuth:createParameterString( $params )
      ),
      oAuth:createSigningKey(
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
        oAuth:buildHeaderString( $headerMap )
      )
    }
    catch *{
      util:log-system-out( 'ERROR: ' ||   $err:line-number || ':' || $err:description )
      }
};

(:~
@see https://dev.twitter.com/oauth/overview/creating-signature
@see https://dev.twitter.com/oauth/overview/authorizing-requests
should produce the the Authorization header value for a twitter API call
@see modules/tests/lib/oAuth.xqm;t-oAuth:buildHeaderString 
@param $map map of params
@return string  oAuth header value
:)
declare
function oAuth:buildHeaderString(
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
createParameterString SHOULD return a percent encoded string
@see modules/tests/lib/oAuth.xqm;t-oAuth:createParameterString
@param $params map of params
@return string 
:)
declare function oAuth:createParameterString(
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

(: TODO! above use sort after eXist implements sort
    map:for-each( $params,
      function( $key, $value ) {
        concat(
        encode-for-uri( $key ),
        '=',
        encode-for-uri( $value )
        )
        }
      )
:)

(:~
createSignatureBaseString SHOULD return a percent encoded string
https://dev.twitter.com/oauth/overview/creating-signatures
To encode the HTTP method, base URL, and parameter string into a single string:
 - Convert the HTTP Method to uppercase and set the output string equal to this value.
 - Append the ‘&’ character to the output string.
 - Percent encode the URL and append it to the output string.
 - Append the ‘&’ character to the output string.
 - Percent encode the parameter string and append it to the output string
@see modules/tests/lib/oAuth.xqm;t-oAuth:createSignatureBaseString
@param $method  as xs:string,
@return string 
:)
declare function oAuth:createSignatureBaseString(
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
createSigningKey SHOULD return a percent encoded string
@see modules/tests/lib/oAuth.xqm;t-oAuth:createSigningKey
@param $consumerSecret  Consumer secreti
@param $accessTokenSecret  OAuth token secret
@return string 
:)
declare function oAuth:createSigningKey(
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
calculateSignature SHOULD return a base64 encoded string
@see modules/tests/lib/oAuth.xqm;t-oAuth:calculateSignature
@param $signatureBaseString  percent encoded base string 
@param $signingKey percent encoded signing key 
@return base64 string
:)
declare function oAuth:calculateSignature(
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

declare function oAuth:createNonce() as xs:string {
  util:uuid()
};

(:
@see https://gist.github.com/joewiz/5929809
Generates an OAuth timestamp, which takes the form of
the number of seconds since the Unix Epoch. You can test
these values against http://www.epochconverter.com/.
@see http://en.wikipedia.org/wiki/Unix_time 
:)
declare function oAuth:createTimeStamp() as xs:unsignedLong {
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



