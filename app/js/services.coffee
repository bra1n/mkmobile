mkmobileServices = angular.module 'mkmobileServices', ['ngResource']

mkmobileServices.factory 'MkmApi', ['$resource', '$q', ($resource, $q) ->
  $resource '/api.php', {},
    search:
      method: 'GET'
      params: {search:""}
      cache: yes
      unique: yes

    articles:
      method: 'GET'
      params: {articles:""}
      cache: yes
]