mkmobileApp = angular.module 'mkmobileApp', [
  # core modules
  'ngRoute'
  'ngSanitize'
  # i18n
  'tmh.dynamicLocale'
  'pascalprecht.translate'
  # app modules
  'mkmobile.controllers'
  'mkmobile.filters'
  'mkmobile.services'
  'mkmobile.directives'
  # templates
  'templates'
  'locales'
  'translations'
]

angular.module 'templates', [] # placeholder for real templates
angular.module 'translations', [] # placeholder for real translations
angular.module 'locales', [] # placeholder for real locales

mkmobileApp.config ['$locationProvider','$routeProvider', ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode yes
  $routeProvider
  # static pages
  .when '/home',
    templateUrl:  '/partials/pages/home.html'
    controller:   'HomeCtrl'
  .when '/help',
    templateUrl:  '/partials/pages/help.html'
    controller:   'HomeCtrl'
  .when '/contact',
    templateUrl:  '/partials/pages/contact.html'
    controller:   'HomeCtrl'

  # payment pages
  .when '/payment/:method',
    templateUrl:  '/partials/pages/payment.html'
    controller:   'PaymentCtrl'

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
  .when '/cart/checkout/:method',
    templateUrl:  '/partials/pages/checkout.html'
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

  # order management
  .when '/buys',
    templateUrl:  '/partials/pages/orders.html'
    controller:   'OrderCtrl'
  .when '/buys/:orderId',
    templateUrl:  '/partials/pages/order.html'
    controller:   'OrderCtrl'
  .when '/buys/:orderId/evaluate',
    templateUrl:  '/partials/pages/evaluate.html'
    controller:   'OrderCtrl'
  .when '/sells',
    templateUrl:  '/partials/pages/orders.html'
    controller:   'OrderCtrl'
  .when '/sells/:orderId',
    templateUrl:  '/partials/pages/order.html'
    controller:   'OrderCtrl'

  # messages
  .when '/messages',
    templateUrl:  '/partials/pages/messages.html'
    controller:   'MessageCtrl'
  .when '/messages/:userId',
    templateUrl:  '/partials/pages/message.html'
    controller:   'MessageCtrl'

  # anonymous routes
  .when '/login',
    templateUrl:  '/partials/pages/login.html'
    controller:   'LoginCtrl'
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

# configure the $http behaviours
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

# i18n
mkmobileApp.config [
  'tmhDynamicLocaleProvider', '$translateProvider'
  (tmhDynamicLocaleProvider, $translateProvider) ->
    # translations
    language = switch (navigator.language or navigator.userLanguage).toLowerCase().substr(0,2)
      when "fr" then "fr_FR"
      when "de" then "de_DE"
      when "es" then "es_ES"
      when "it" then "it_IT"
      else "en_GB"
    $translateProvider
    .useStaticFilesLoader
      prefix: '/translations/lang-',
      suffix: '.json'
    .fallbackLanguage 'en_GB'
    .preferredLanguage language
    .useSanitizeValueStrategy 'sanitizeParameters'
    # locale
    tmhDynamicLocaleProvider.localeLocationPattern '/lib/angular-i18n/angular-locale_{{locale}}.js'
    tmhDynamicLocaleProvider.defaultLocale language.replace(/_/, '-').toLowerCase()
]

# generate a base CSS class based on the route path and check login for auth routes
mkmobileApp.run [
  '$rootScope','MkmApiAuth','$translate'
  ($rootScope, MkmApiAuth, $translate) ->
    # update title and view class
    translateTitle = -> $translate(['titles.app','titles.'+$rootScope.viewClass]).then (texts) ->
      $rootScope.viewTitle = texts['titles.app'] + ' — ' + texts['titles.'+$rootScope.viewClass]
      $rootScope.language = $translate.use().substr(0,2)
      $rootScope.languageId = MkmApiAuth.getLanguage()

    # check login
    $rootScope.$on '$routeChangeStart', (event, next) ->
      unless next.$$route?.noLogin
        event.preventDefault() unless MkmApiAuth.checkLogin()
    # new page, update view class and title
    $rootScope.$on '$routeChangeSuccess', (event, current) ->
      if current.$$route?.originalPath? and current.$$route?.originalPath.split("/").length > 1
        $rootScope.viewClass = current.$$route?.originalPath.split("/")[1]
        $rootScope.loggedIn = MkmApiAuth.isLoggedIn()
        translateTitle()
    # update title on language change
    $rootScope.$on '$translateChangeSuccess', -> translateTitle()
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
  # add query parameters if present
  for key,value of config.params
    params[key] = encodeURIComponent value #.toString().replace /[ ]/g, '+' # wonky implementation for space encoding
    paramOrder.push key
  signatureParams = []
  signatureParams.push param+"="+params[param] for param in paramOrder.sort()
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
  else if typeof obj isnt "undefined"
    xml = obj.toString().replace /[\u00A0-\u9999<>\&]/gim, (i) -> '&#'+i.charCodeAt(0)+';'
  xml = '<?xml version="1.0" encoding="UTF-8" ?><request>'+xml+'</request>' unless recursive
  xml