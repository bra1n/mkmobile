mkmobileServices = angular.module 'mkmobileServices', ['ngResource']

mkmobileServices.factory 'MkmApi', ['$resource', ($resource) ->
  $resource '/api/:type/:param1/:param2/:param3/:param4/:param5', {},
    search:
      method: 'GET'
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: yes

    articles:
      method: 'GET'
      params: {type:"articles"}
      transformResponse: (data, headers) ->
        response = angular.fromJson data
        # fix the one-off problem where we don't get an array back
        response.article = [].concat response.article
        # handle partial content header
        if headers()['range']?
          response.count = headers()['range'].replace /^.*\//g, ''
        else
          response.count = response['article'].length()
        response

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