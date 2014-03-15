mkmobileApp = angular.module 'mkmobileApp', [
  'ngRoute'
  'ngAnimate'
  'mkmobileControllers'
  'mkmobileFilters'
  'mkmobileServices'
  'mkmobileDirectives'
]

mkmobileApp.config ['$locationProvider','$routeProvider', ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode yes
  $routeProvider
  .when '/login/:search?',
    class:        'login'
    templateUrl:  '/partials/login.html'
    controller:   'SearchCtrl'
    #reloadOnSearch: no
  .when '/product/:productId',
    class:        'product'
    templateUrl:  '/partials/product.html'
    controller:   'ProductCtrl'
  .otherwise
    redirectTo: '/login'
]

mkmobileApp.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.useXDomain = yes
  $httpProvider.defaults.cache = yes
  delete $httpProvider.defaults.headers.common['X-Requested-With']
  $httpProvider.interceptors.push ['$q', ($q) ->
    uniqueRequests = {}
    # if the request has a "unique" flag, cancel any currently running requests with that same flag
    request: (config) ->
      if config.unique
        uniqueRequests[config.unique]?.resolve()
        uniqueRequests[config.unique] = $q.defer()
        config.timeout = uniqueRequests[config.unique].promise
      config or $q.when config
  ]
]

mkmobileApp.run ['$rootScope', ($rootScope) ->
  $rootScope.$on '$routeChangeSuccess', (event, current, previous) ->
    $rootScope.viewClass = current.$$route.class
]