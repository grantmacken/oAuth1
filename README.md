# oAuth1
Create Authorization Headers for Twitter API calls

This lib only purpose is to enable calls to Twitter API endpoints via
 OAuth 1.0a protocol [Authorization Header](https://developer.twitter.com/en/docs/basics/authentication/guides/authorizing-a-request) 

## Prior to using this library

You must obtain your twitter [access token](https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens)
from the [twitter apps dashboard](https://developer.twitter.com/en/apps)
You will end up with your 4 credential items
    1. oauth_consumer_key
    2. oauth_consumer_secret
    3. oauth_token_secret
    4. oauth_token

Next make yourself familiar with the [Twitter API docs](https://developer.twitter.com/en/docs.html)

The API call you are most likely interest in are in the [post and engage overview section](https://developer.twitter.com/en/docs/tweets/post-and-engage/overview)

## Creating a Authorization Header

Th following example shows how to use the library, with your obtained credentials.
It creates the Authorization header string required for posting a status update to the Twitter 'statuses/update' API endpoint

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


