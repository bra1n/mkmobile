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
  # home page
  .when '/home',
    templateUrl:  '/partials/pages/home.html'
    controller:   'HomeCtrl'

  # search
  .when '/search',
    templateUrl:  '/partials/pages/search.html'
    controller:   'SearchCtrl'

  # shopping cart
  .when '/cart',
    templateUrl:  '/partials/pages/cart.html'
    controller:   'CartCtrl'
  .when '/cart/address',
    templateUrl:  '/partials/pages/address.html'
    controller:   'CartCtrl'
  .when '/cart/:orderId',
    templateUrl:  '/partials/pages/order.html'
    controller:   'CartCtrl'

  # stock management
  .when '/stock',
    templateUrl:  '/partials/pages/stock.html'
    controller:   'StockCtrl'
  .when '/stock/:articleId',
    templateUrl:  '/partials/pages/article.html'
    controller:   'StockCtrl'

  # user settings
  .when '/settings',
    templateUrl:  '/partials/pages/settings.html'
    controller:   'SettingsCtrl'

  # offer management
  .when '/buys',
    templateUrl:  '/partials/pages/orders.html'
    controller:   'OrderCtrl'
  .when '/buys/:orderId',
    templateUrl:  '/partials/pages/order.html'
    controller:   'OrderCtrl'
  .when '/sells',
    templateUrl:  '/partials/pages/orders.html'
    controller:   'OrderCtrl'
  .when '/sells/:orderId',
    templateUrl:  '/partials/pages/order.html'
    controller:   'OrderCtrl'

  # messages
  .when '/messages/:user?',
    templateUrl:  '/partials/pages/messages.html'
    controller:   'MessageCtrl'

  # anonymous routes
  .when '/login',
    templateUrl:  '/partials/pages/login.html'
    controller:   'SearchCtrl'
    noLogin:      yes
  .when '/product/:productId',
    templateUrl:  '/partials/pages/product.html'
    controller:   'ProductCtrl'
    noLogin:      yes
  .when '/callback',
    templateUrl:  '/partials/pages/callback.html'
    controller:   'CallbackCtrl'
    noLogin:      yes
  .otherwise
    redirectTo: '/home'
]

mkmobileApp.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.useXDomain = yes
  delete $httpProvider.defaults.headers.common['X-Requested-With']
  $httpProvider.interceptors.push ['$q', ($q) ->
    uniqueRequests = {}
    # - if the request has a "unique" flag, cancel any currently running requests with that same flag
    # - generate OAuth header if provided
    # - transform payload into XML if right content type
    request: (config) ->
      if config.unique
        uniqueRequests[config.unique]?.resolve()
        uniqueRequests[config.unique] = $q.defer()
        config.timeout = uniqueRequests[config.unique].promise
      config.headers.Authorization = generateOAuthHeader config if config.oauth?
      config.transformRequest = ((data) -> toXML data) if config.headers['Content-type']?
      config or $q.when config
    # if the response has a Range header, parse it and put it into the data as _count property
    response: (response) ->
      if response.headers()['content-range']?
        response.data._range = parseInt(response.headers()['content-range'].replace(/^.*\//,''),10) or 0
      response or $q.when response
  ]
]

# generate a base CSS class based on the route path and check login for auth routes
mkmobileApp.run [ '$rootScope','MkmApiAuth', ($rootScope, MkmApiAuth) ->
  $rootScope.$on '$routeChangeStart', (event, next) ->
    unless next.$$route.noLogin
      event.preventDefault() unless MkmApiAuth.checkLogin()
  $rootScope.$on '$routeChangeSuccess', (event, current) ->
    if current.$$route?.originalPath? and current.$$route?.originalPath.split("/").length > 1
      $rootScope.viewClass = current.$$route?.originalPath.split("/")[1]
]

# init services and controllers
mkmobileServices = angular.module 'mkmobileServices', ['ngResource']
mkmobileControllers = angular.module 'mkmobileControllers', []

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

# transform object into XML string
toXML = (obj, recursive = no) ->
  xml = ''
  if typeof obj is "object"
    for prop,val of obj
      if typeof val is "object"
        if val instanceof Array
          val = val.map((elem) -> toXML elem, yes).join "</#{prop}><#{prop}>"
        else
          val = toXML val, yes
      else if typeof val isnt "undefined"
        val = val.toString().replace /[\u00A0-\u9999<>\&]/gim, (i) -> '&#'+i.charCodeAt(0)+';'
      xml += "<#{prop}>#{val}</#{prop}>"
  else
    xml = obj.toString().replace /[\u00A0-\u9999<>\&]/gim, (i) -> '&#'+i.charCodeAt(0)+';'
  xml = '<?xml version="1.0" encoding="UTF-8" ?><request>'+xml+'</request>' unless recursive
  xml