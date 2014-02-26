mkmobileServices = angular.module 'mkmobileServices', ['ngResource']

mkmobileServices.factory 'MkmApi', ['$resource', ($resource) ->
  apiURL = '/api'
  # apiURL = 'https://www.mkmapi.eu/ws/bra1n/###/output.json'
  $resource apiURL+'/:type/:param1/:param2/:param3/:param4/:param5', {},
    search:
      method: 'GET'
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: "search"

    articles:
      method: 'GET'
      params: {type:"articles"}
      cache: no

    product:
      method: 'GET'
      params: {type:"product"}
]

mkmobileServices.factory 'DataCache', ['$cacheFactory', ($cacheFactory) ->
  # all glory to the mighty cache object
  cache =
    product: $cacheFactory 'products', capacity: 500
  product: (id, data) ->
    cache.product.put(id, data) if data?
    cache.product.get(id) if id?
]