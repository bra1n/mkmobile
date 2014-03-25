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
  .when '/',
    templateUrl:  '/partials/home.html'
    controller:   'HomeCtrl'
  .when '/search',
    templateUrl:  '/partials/search.html'
    controller:   'SearchCtrl'
  .when '/settings',
    templateUrl:  '/partials/settings.html'
    controller:   'SettingsCtrl'
  .when '/login',
    templateUrl:  '/partials/login.html'
    controller:   'SearchCtrl'
  .when '/product/:productId',
    templateUrl:  '/partials/product.html'
    controller:   'ProductCtrl'
  .when '/callback',
    templateUrl:  '/partials/callback.html'
    controller:   'CallbackCtrl'
  .otherwise
    redirectTo: '/'
]

# helper function to generate oauth headers
generateOAuthHeader = (config) ->
  auth = config.oauth
  params =
    realm: config.url
    oauth_consumer_key: auth.consumerKey
    oauth_nonce: Math.random().toString(36).substr(2)+Math.random().toString(36).substr(2)
    oauth_signature_method: "HMAC-SHA1"
    oauth_timestamp: Math.round(new Date().getTime()/1000)
    oauth_token: auth.token
    oauth_version: "1.0"
    oauth_signature: ""
  paramOrder = ["oauth_consumer_key","oauth_nonce","oauth_signature_method","oauth_timestamp","oauth_token","oauth_version"]
  signatureParams = []
  signatureParams.push param+"="+params[param] for param in paramOrder
  signature = [ config.method, encodeURIComponent(params.realm), encodeURIComponent(signatureParams.join "&")].join "&"
  salt = encodeURIComponent(auth.consumerSecret) + "&" + encodeURIComponent(auth.secret)
  console.log "building oauth headers", auth, signature, salt
  signature = CryptoJS.HmacSHA1 signature, salt
  params.oauth_signature = signature.toString CryptoJS.enc.Base64

  'OAuth
    realm="'+params.realm+'",
    oauth_version="'+params.oauth_version+'",
    oauth_timestamp="'+params.oauth_timestamp+'",
    oauth_nonce="'+params.oauth_nonce+'",
    oauth_consumer_key="'+params.oauth_consumer_key+'",
    oauth_token="'+params.oauth_token+'",
    oauth_signature_method="'+params.oauth_signature_method+'",
    oauth_signature="'+params.oauth_signature+'"
  '

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
      config.headers.Authorization = generateOAuthHeader config if config.oauth?
      config or $q.when config
  ]
]

# generate a base CSS class based on the template name
mkmobileApp.run ['$rootScope', ($rootScope) ->
  $rootScope.$on '$routeChangeSuccess', (event, current) ->
    $rootScope.viewClass = current.$$route?.templateUrl.replace(/(^.*\/|\.html$)/ig,'')
]