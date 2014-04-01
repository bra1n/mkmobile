mkmobileServices = angular.module 'mkmobileServices', ['ngResource']

mkmobileServices.factory 'MkmApi', [ '$resource', '$location', 'DataCache',
($resource, $location, DataCache) ->
  ## variables
  auth =
    consumerKey: "alb03sLPpFNAhi6f"
    consumerSecret: "HTIcbso87X22JdS3Yk89c2CojfZiNDMX"
    token: sessionStorage.getItem("token") or ""
    secret: sessionStorage.getItem("secret") or ""
  apiURL    = 'https://www.mkmapi.eu/ws'
  apiAuth   = '/bra1n/a042b2e17c5cba981d6f684ec338b98a'
  apiFormat = '/output.json'
  api       = $resource apiURL+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5', {},
    search:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: "search"
      oauth: auth
    articles:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: "articles"
      cache: no
      oauth: auth
    product:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: "product"
      oauth: auth
    access:
      method: 'POST'
      params: type: "access"
      headers: {'Content-type': 'application/xml'}
      oauth: auth
    cartUpdate:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      method: 'PUT'
      params: type: 'shoppingcart'
      headers: {'Content-type': 'application/xml'}
      oauth: auth
    shoppingcart:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: 'shoppingcart'
      oauth: auth
    stock:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: 'stock'
      oauth: auth
      cache: no
    stockUpdate:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: 'stock'
      headers: {'Content-type': 'application/xml'}
      method: 'PUT'
      oauth: auth

  ## interfaces
  cart: new ServiceCart {cache:DataCache, api}
  stock: new ServiceStock {cache:DataCache, api}
  market: new ServiceMarket {cache:DataCache, api}
  auth: new ServiceAuth {api, auth, location: $location}
]

mkmobileServices.factory 'DataCache', ['$cacheFactory', ($cacheFactory) ->
  # all glory to the mighty cache object
  cache =
    product: $cacheFactory 'products', capacity: 500
    article: $cacheFactory 'article', capacity: 1000
    cart: $cacheFactory 'cart', capacity: 2
    user: $cacheFactory 'user', capacity: 1
  product: (id, data) ->
    cache.product.put(id, data) if data?
    cache.product.get(id) if id?
  article: (id, data) ->
    # todo take out once the api returns the right format
    if data?
      data.price = parseFloat(data.price) if data.price?
      data.count = parseInt(data.count, 10) if data.count?
    cache.article.put(id, data) if data?
    cache.article.remove(id) if data is false
    cache.article.get(id) if id?
  cart: (data) ->
    if data?
      # todo replace with API field for "total count per seller"
      for seller,index in data
        count = 0
        count += parseInt(article.count, 10) for article in seller.article
        data[index].totalCount = count
      # end of replace
      cache.cart.put('cart', data) if data?
    cache.cart.get('cart')
  cartCount: (count) ->
    cache.cart.put('count', count) if count?
    cache.cart.get('count') or 0
  user: (data) ->
    cache.user.put(1, data) if data?
    cache.user.get(1) or []
]