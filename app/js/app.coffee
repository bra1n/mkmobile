mkmobileApp = angular.module 'mkmobileApp', [
  'ngRoute',
  'mkmobileControllers',
  'mkmobileFilters',
  'mkmobileServices'
]

mkmobileApp.config ['$routeProvider', ($routeProvider) ->
    $routeProvider
    .when '/search',
      templateUrl:    'partials/search.html'
      controller:     'SearchCtrl'
      reloadOnSearch: no
    .when '/products/:productId',
        templateUrl:  'partials/product.html'
        controller:   'ProductCtrl'
    .otherwise
        redirectTo: '/search'
]

mkmobileApp.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push ['$q', ($q) ->
    uniqueRequests = {}
    request: (config) ->
      if config.unique
        uniqueRequests[config.unique]?.resolve()
        uniqueRequests[config.unique] = $q.defer()
        config.timeout = uniqueRequests[config.unique].promise;
      config or $q.when(config)
  ]
]