# oAuth1
Create Authorization Headers for Twitter API calls

This lib only purpose is to enable authenticate calls to Twitter API endpoints via an oAuth 1 authorization Header

## How to use this library

 - Go to twitter and obtain your 4 credentials that will enable you to make twitter api calls via the oAuth 1 protocal. You will need
  1. oauth_consumer_key
  2. oauth_consumer_secret
  3. oauth_token_secret
  4. oauth_token

To make an API check out the [Twitter API docs](https://developer.twitter.com/en/docs.html)
The API call you are most likely interest in are in the [post and engage overview section](https://developer.twitter.com/en/docs/tweets/post-and-engage/overview)

To create an *Authorization Header* collect the following items
 1. method: e.g. [POST] the API http call method
 2. resource e.g. [https://api.twitter.com/1.1/statuses/update ] the API resource 
 3. your 4 credential items
 4. your json request: e.g. { 'status': 'hi de hi' }

A example in bash which will create a Header for the posting a 'myTweet' status to the Twitter 'statuses/update' API endpoint

WIP TODO! have not tested script below
```
myTweet='Hi de hi'
oauth_consumer_key='xxxx'
oauth_consumer_secret='xxxx'
oauth_token_secret='xxxx'
oauth_token='xxx'

function post() {
curl  -s \
  -H 'Content-Type: application/xml' \
  -u 'admin:' \
  --data-binary @- "$URL"
}
cat <<EOF | post
<query xmlns="http://exist.sourceforge.net/NS/exist"
 start='1'
 max='9999'
 wrap="no">
<text>
<![CDATA[
xquery version "3.1";
import module namespace oAuth="http://markup.nz/#oAuth1";
try{
map {
    'method' : 'POST',
    'resource' : 'https://api.twitter.com/1.1/statuses/update',
    'oauth_consumer_key' : '$oauth_consumer_key',
    'oauth_consumer_secret' : '$oauth_consumer_secret',
    'oauth_token_secret' : '$oauth_token_secret,
    'oauth_token' : '$oauth_token'
    } => 
 oAuth:authorizationHeader( map {'status' '$myTweet' })
} catch * {()}
]] ..']]>' .. [[
</text>
</query>
```


