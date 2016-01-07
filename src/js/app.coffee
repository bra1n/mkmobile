mkmobileApp = angular.module 'mkmobileApp', [
  # core modules
  'ui.router'
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

mkmobileApp.config [
  '$locationProvider', '$stateProvider', '$urlRouterProvider'
  ($locationProvider, $stateProvider, $urlRouterProvider) ->
    $locationProvider.html5Mode yes
    $stateProvider
    # static pages
    .state 'home',
      url: '/home'
      templateUrl:  '/partials/pages/home.html'
      controller:   'HomeCtrl'
    .state 'help',
      url: '/help'
      templateUrl:  '/partials/pages/help.html'
      controller:   'HomeCtrl'
    .state 'imprint',
      url: '/imprint'
      templateUrl:  '/partials/pages/imprint.html'
      controller:   'HomeCtrl'
    .state 'contact',
      url: '/contact'
      templateUrl:  '/partials/pages/contact.html'
      controller:   'HomeCtrl'

    # payment pages
    .state 'payment',
      url: '/payment/:method',
      templateUrl:  '/partials/pages/payment.html'
      controller:   'PaymentCtrl'

    # search
    .state 'search',
      url: '/search'
      templateUrl:  '/partials/pages/search.html'
      controller:   'SearchCtrl'

    # shopping cart
    .state 'cart',
      url: '/cart'
      templateUrl:  '/partials/pages/cart.html'
      controller:   'CartCtrl'
    .state 'cart.address',
      url: '/address'
      templateUrl:  '/partials/pages/address.html'
    .state 'cart.checkout',
      url: '/checkout/:method'
      templateUrl:  '/partials/pages/checkout.html'
    .state 'cart.order',
      url: '/:orderId',
      templateUrl:  '/partials/pages/order.html'

    # stock management
    .state 'stock',
      url: '/stock'
      templateUrl:  '/partials/pages/stock.html'
      controller:   'StockCtrl'
    .state 'stock.article',
      url: '/:articleId'
      templateUrl:  '/partials/pages/article.html'

    # user settings
    .state 'settings',
      url: '/settings'
      templateUrl:  '/partials/pages/settings.html'
      controller:   'SettingsCtrl'

    # order management
    .state 'buys',
      url: '/buys'
      templateUrl:  '/partials/pages/orders.html'
      controller:   'OrderCtrl'
    .state 'buys.order',
      url: '/:orderId'
      templateUrl:  '/partials/pages/order.html'
    .state 'buys.evaluate',
      url: '/:orderId/evaluate'
      templateUrl:  '/partials/pages/evaluate.html'
    .state 'sells',
      url: '/sells'
      templateUrl:  '/partials/pages/orders.html'
      controller:   'OrderCtrl'
    .state 'sells.order',
      url: '/:orderId'
      templateUrl:  '/partials/pages/order.html'

    # messages
    .state 'messages',
      url: '/messages'
      templateUrl:  '/partials/pages/messages.html'
      controller:   'MessageCtrl'
    .state 'messages.user',
      url: '/:userId'
      templateUrl:  '/partials/pages/message.html'

    # anonymous routes
    .state 'login',
      url: '/login'
      templateUrl:  '/partials/pages/login.html'
      controller:   'LoginCtrl'
      noLogin:      yes
    .state 'product',
      url: '/product/:idProduct'
      templateUrl:  '/partials/pages/product.html'
      controller:   'ProductCtrl'
      noLogin:      yes
    .state 'callback',
      url: '/callback'
      templateUrl:  '/partials/pages/callback.html'
      controller:   'CallbackCtrl'
      noLogin:      yes
    $urlRouterProvider.otherwise '/home'
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
    $rootScope.$on '$stateChangeStart', (event, next) ->
      unless next.noLogin
        event.preventDefault() unless MkmApiAuth.checkLogin()
    # new page, update view class and title
    $rootScope.$on '$stateChangeSuccess', (event, current) ->
      if current.name
        $rootScope.viewClass = current.name
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