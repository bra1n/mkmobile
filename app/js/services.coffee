mkmobileServices = angular.module 'mkmobileServices', ['ngResource']

mkmobileServices.factory 'MkmApi', [ '$resource', '$location', 'DataCache', '$http',
($resource, $location, DataCache, $http) ->
  apiURL = '/api'
  # apiURL = 'https://www.mkmapi.eu/ws/bra1n/###/output.json'
  api = $resource apiURL+'/:type/:param1/:param2/:param3/:param4/:param5', {},
    search:
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: "search"
    articles:
      params: {type:"articles"}
      cache: no
    product:
      params: {type:"product"}

  parseRangeHeader = (headers) -> if headers().range? then parseInt(headers().range.replace(/^.*\//,''),10) else 0
  loggedIn = false
  redirectAfterLogin = false

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
    unless loggedIn
      redirectAfterLogin = $location.path()
      $location.path '/login'
    loggedIn
  # log the user in
  login: ->
    $http
      method: 'POST'
      url: 'https://www.mkmapi.eu/ws/authenticate'
      headers:
        'Content-type': 'application/xml'
      data: '<?xml version="1.0" encoding="UTF-8" ?><request><app_key>alb03sLPpFNAhi6f</app_key><callback_uri>http://mobile.local/?requestToken=</callback_uri></request>'
    .success (data, status) ->
        console.log data, status
    .error (data, status) ->
        console.error data, status
    #loggedIn = yes
    #$location.path redirectAfterLogin if redirectAfterLogin
]

mkmobileServices.factory 'DataCache', ['$cacheFactory', ($cacheFactory) ->
  # all glory to the mighty cache object
  cache =
    product: $cacheFactory 'products', capacity: 500
  product: (id, data) ->
    cache.product.put(id, data) if data?
    cache.product.get(id) if id?
]