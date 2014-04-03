mkmobileServices.factory 'MkmApi', [ '$resource', 'DataCache', ($resource, DataCache) ->
  auth =
    consumerKey:    "alb03sLPpFNAhi6f"
    consumerSecret: "HTIcbso87X22JdS3Yk89c2CojfZiNDMX"
    token:          sessionStorage.getItem("token") or ""
    secret:         sessionStorage.getItem("secret") or ""
  apiURL    = 'https://www.mkmapi.eu/ws'
  apiAuth   = '/bra1n/a042b2e17c5cba981d6f684ec338b98a'
  apiFormat = '/output.json'
  api: $resource apiURL+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5', {},
    search:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: "search"
      cache: yes
      oauth: auth
    articles:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: "articles"
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
    stockUpdate:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: 'stock'
      headers: {'Content-type': 'application/xml'}
      method: 'PUT'
      oauth: auth
    stockAmount:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: {type: 'stock', param1: 'article', param2: "@param2", param3: "@param3", param4: "@param4"}
      method: 'PUT'
      oauth: auth
    orders:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: 'orders'
      oauth: auth
      cache: yes
      unique: "order"
    order:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: 'order'
      oauth: auth
  auth: auth
]