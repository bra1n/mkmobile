mkmobileServices.factory 'MkmApi', [ '$resource', ($resource) ->
  auth =
    consumerKey:    "alb03sLPpFNAhi6f"
    consumerSecret: "HTIcbso87X22JdS3Yk89c2CojfZiNDMX"
    token:          sessionStorage.getItem("token") or ""
    secret:         sessionStorage.getItem("secret") or ""
  apiURL    = 'https://www.mkmapi.eu/ws'
  apiAuth   = '/bra1n/a042b2e17c5cba981d6f684ec338b98a'
  apiFormat = '/output.json'
  apiParams =
    search:
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: "search"
      cache:  yes
    articles:
      params: type: "articles"
    product:
      params: type: "product"
    access:
      params: type: "access"
      method: 'POST'
    shoppingcart:
      params: type: 'shoppingcart'
    cartUpdate:
      params: type: 'shoppingcart'
      method: 'PUT'
    stock:
      params: type: 'stock'
    stockUpdate:
      params: type: 'stock'
      method: 'PUT'
    stockAmount:
      params: {type: 'stock', param1: 'article', param2: "@param2", param3: "@param3", param4: "@param4"}
      method: 'PUT'
    orders:
      params: type: 'orders'
      unique: "order"
      cache:  yes #todo: don't cache
    order:
      params: type: 'order'
    orderUpdate:
      params: type: 'order'
      method: 'PUT'
  # augment the configs
  for param,config of apiParams
    # oauth for all the requests
    apiParams[param].pauth = auth
    # PUT / POST should send the right content-type header
    apiParams[param].headers = {'Content-type': 'application/xml'} if config.method in ['PUT', 'POST']
    # use the old API url until the new version is live
    apiParams[param].url = apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' unless param is "access"
  api: $resource apiURL+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5', {}, apiParams
  auth: auth
]