# oAuth1
Create Authorization Headers for Twitter API calls

This lib only purpose is to enable calls to Twitter API endpoints via
 OAuth 1.0a protocol [Authorization Header](https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request) 

## Prior to using this library

Ypu must obtain your twitter [access token](https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens)
Go to [twitter apps dashboard](https://developer.twitter.com/en/apps) and obtain your 4 credentials.
  1. oauth_consumer_key
  2. oauth_consumer_secret
  3. oauth_token_secret
  4. oauth_token

Make yourself familiar with the [Twitter API docs](https://developer.twitter.com/en/docs.html)

The API call you are most likely interest in are in the [post and engage overview section](https://developer.twitter.com/en/docs/tweets/post-and-engage/overview)

## Creating a Authorization Header

Collect the following items
 1. method: e.g. [POST] the API http call method
 2. resource e.g. [https://api.twitter.com/1.1/statuses/update ] the API resource 
 3. your 4 credential items obtained fro twitter
 4. your json request: e.g. { 'status': 'hi de hi' }

A example which will create a Header for the postinga status to the Twitter 'statuses/update' API endpoint

```
declare
function oAuth1:example() as xs:string {
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
)
};

```


