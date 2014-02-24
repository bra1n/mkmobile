mkmobileServices = angular.module 'mkmobileServices', ['ngResource']

mkmobileServices.factory 'MkmApi', ['$resource', ($resource) ->
  $resource '/api/:type/:param1/:param2/:param3/:param4', {},
    search:
      method: 'GET'
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: yes

    articles:
      method: 'GET'
      params: {type:"articles"}

    product:
      method: 'GET'
      params: {type:"product"}
]

mkmobileServices.factory 'DataCache', ->
  # all glory to the mighty cache object
  cache =
    product: {}
  product: (id, data) ->
    cache.product[id] = data if data?
    cache.product[id] if id?