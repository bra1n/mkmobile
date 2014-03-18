mkmobileServices = angular.module 'mkmobileServices', ['ngResource']

mkmobileServices.factory 'MkmApi', [ '$resource', '$location', 'DataCache',
($resource, $location, DataCache) ->
  ## helper functions
  parseRangeHeader = (headers) -> if headers().range? then parseInt(headers().range.replace(/^.*\//,''),10) else 0
  generateOAuthHeader = (config) ->
    params =
      realm: config.url
      oauth_consumer_key: auth.consumerKey
      oauth_nonce: Math.random().toString(36).substr(2)+Math.random().toString(36).substr(2)
      oauth_signature_method: "HMAC-SHA1"
      oauth_timestamp: new Date().getTime()
      oauth_token: auth.token
      oauth_version: "1.0"
      oauth_signature: ""
    paramOrder = ["oauth_consumer_key","oauth_nonce","oauth_signature_method","oauth_timestamp","oauth_token","oauth_version"]
    signatureParams = []
    signatureParams.push param+"="+params[param] for param in paramOrder
    signature = [ config.method, encodeURIComponent(params.realm), encodeURIComponent(signatureParams.join "&")].join "&"
    salt = encodeURIComponent(auth.consumerSecret) + "&" + encodeURIComponent(auth.secret)
    console.log "output", signature, salt
    signature = CryptoJS.HmacSHA1 signature, salt
    params.oauth_signature = signature.toString CryptoJS.enc.Base64

    'OAuth
      realm="'+params.realm+'",
      oauth_version="'+params.oauth_version+'",
      oauth_timestamp="'+params.oauth_timestamp+'",
      oauth_nonce="'+params.oauth_nonce+'",
      oauth_consumer_key="'+params.oauth_consumer_key+'",
      oauth_token="'+params.oauth_token+'",
      oauth_signature_method="'+params.oauth_signature_method+'",
      oauth_signature="'+params.oauth_signature+'"
    '

  ## variables
  apiURL = 'https://www.mkmapi.eu/ws/bra1n/a042b2e17c5cba981d6f684ec338b98a/output.json'
  auth =
    consumerKey: "alb03sLPpFNAhi6f"
    consumerSecret: "HTIcbso87X22JdS3Yk89c2CojfZiNDMX"
    token: ""
    secret: ""
  redirectAfterLogin = false
  api = $resource apiURL+'/:type/:param1/:param2/:param3/:param4/:param5', {},
    search:
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: "search"
      oauth: generateOAuthHeader.bind @
    articles:
      params: type:"articles"
      cache: no
    product:
      params: type:"product"
    access:
      method: 'POST'
      params: type: "access"
      headers: {'Content-type': 'application/xml'}
      oauth: generateOAuthHeader.bind @

  ## interface
  # search for a product
  search: (query, response) ->
    # if response isn't passed in, create a base object that will be filled later
    response = count: 0, products: [] unless response?
    if query
      # toggle loading flag
      response.loading = yes
      # query the API
      api.search {param1: query, param5: response.products.length + 1}, (data, headers) ->
        # cache products
        data.product?.map (val) -> DataCache.product val.idProduct, val
        # update count
        response.count = parseRangeHeader(headers) or data.product?.length
        # merge products
        response.products = response.products.concat data.product if response.count
        # toggle loading flag
        response.loading = no
    # return the base object
    response
  # get product data
  product: (id) ->
    response = product: DataCache.product id
    unless response.product? # no product data in cache, retrieve it!
      api.product param1: id, (data) ->
        response.product = DataCache.product id, data.product
    response
  # get articles for a product
  articles: (id, response) ->
    response = count: 0, articles: [] unless response?
    response.loading = yes
    api.articles {param1: id, param2: response.articles.length + 1}, (data, headers) ->
      response.count = parseRangeHeader(headers) or data.article?.length
      response.articles = response.articles.concat data.article if response.count
      response.loading = no
    response
  # get login status
  isLoggedIn: ->
    if auth.token is ""
      redirectAfterLogin = $location.path()
      $location.path '/login'
    auth.token isnt ""
  # return login URL
  getLoginURL: ->
    apiURL + '/authenticate/' + auth.consumerKey
  # log the user in
  getAccess: (requestToken) ->
    payload = '<?xml version="1.0" encoding="UTF-8" ?><request><app_key>'+auth.consumerKey+'</app_key>
               <request_token>'+requestToken+'</request_token></request>'
    api.access payload, (data) ->
      console.log data
      #loggedIn = yes
      #$location.path redirectAfterLogin
]

mkmobileServices.factory 'DataCache', ['$cacheFactory', ($cacheFactory) ->
  # all glory to the mighty cache object
  cache =
    product: $cacheFactory 'products', capacity: 500
  product: (id, data) ->
    cache.product.put(id, data) if data?
    cache.product.get(id) if id?
]