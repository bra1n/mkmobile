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
      url:          '/home'
      templateUrl:  '/partials/pages/home.html'
      controller:   'HomeCtrl'

    # payment pages
    .state 'payment',
      url:          '/payment/:method',
      templateUrl:  '/partials/pages/payment.html'
      controller:   'PaymentCtrl'

    # search
    .state 'search',
      url:          '/search'
      templateUrl:  '/partials/pages/search.html'
      controller:   'SearchCtrl'

    # shopping cart
    .state 'cart',
      abstract:     yes
      url:          '/cart'
      template:     '<ui-view/>'
    .state 'cart.list',
      url:          ''
      templateUrl:  '/partials/pages/cart.html'
      controller:   'CartCtrl'
    .state 'cart.address',
      url:          '/address'
      templateUrl:  '/partials/pages/cart.address.html'
      controller:   'CartCtrl'
    .state 'cart.checkout',
      url:          '/checkout/:method'
      templateUrl:  '/partials/pages/cart.checkout.html'
      controller:   'CartCtrl'
    .state 'cart.order',
      url:          '/:orderId',
      templateUrl:  '/partials/pages/order.single.html'
      controller:   'CartCtrl'

# stock management
    .state 'stock',
      abstract:     yes
      url:          '/stock'
      template:     '<ui-view/>'
    .state 'stock.list',
      url:          ''
      templateUrl:  '/partials/pages/stock.html'
      controller:   'StockCtrl'
    .state 'stock.article',
      url:          '/:articleId'
      templateUrl:  '/partials/pages/article.html'
      controller:   'StockCtrl'

    # user profile
    .state 'profile',
      abstract:     yes
      url:          '/profile'
      template:     '<ui-view/>'
    .state 'profile.account',
      url:          ''
      templateUrl:  '/partials/pages/profile.account.html'
      controller:   'ProfileCtrl as profile'
    .state 'profile.credit',
      url:          '/credit'
      templateUrl:  '/partials/pages/profile.credit.html'
      controller:   'ProfileCtrl as profile'
    .state 'profile.coupon',
      url:          '/coupon'
      templateUrl:  '/partials/pages/profile.coupon.html'
      controller:   'ProfileCtrl as profile'
    .state 'profile.user',
      url:          '/:idUser'
      templateUrl:  '/partials/pages/profile.user.html'
      controller:   'UserCtrl as user'
      noLogin:      yes

    # order management
    .state 'order',
      abstract:     yes
      url:          '/order'
      template:     '<ui-view/>'
    .state 'order.buy',
      url:          '/buy'
      templateUrl:  '/partials/pages/order.list.html'
      controller:   'OrderCtrl'
    .state 'order.sell',
      url:          '/sell'
      templateUrl:  '/partials/pages/order.list.html'
      controller:   'OrderCtrl'
    .state 'order.single',
      url:          '/:idOrder'
      templateUrl:  '/partials/pages/order.single.html'
      controller:   'OrderCtrl'
    .state 'order.evaluate',
      url:          '/:idOrder/evaluate'
      templateUrl:  '/partials/pages/order.evaluate.html'
      controller:   'OrderCtrl'

    # messages
    .state 'message',
      abstract:     yes
      url:          '/message'
      template:     '<ui-view/>'
    .state 'message.list',
      url:          ''
      templateUrl:  '/partials/pages/message.list.html'
      controller:   'MessageCtrl'
    .state 'message.user',
      url:          '/:idUser'
      templateUrl:  '/partials/pages/message.user.html'
      controller:   'MessageCtrl'

    # wantslists
    .state 'wantslist',
      abstract:     yes
      url:          '/wantslist'
      template:     '<ui-view/>'
    .state 'wantslist.list',
      url:          ''
      templateUrl:  '/partials/pages/wantslist.list.html'
      controller:   'WantslistCtrl as wantslist'
    .state 'wantslist.single',
      url:          '/:idWantsList'
      templateUrl:  '/partials/pages/wantslist.single.html'
      controller:   'WantslistCtrl as wantslist'

    # anonymous routes
    .state 'imprint',
      url:          '/imprint'
      templateUrl:  '/partials/pages/imprint.html'
      controller:   'HomeCtrl'
      noLogin:      yes
    .state 'contact',
      url:          '/contact'
      templateUrl:  '/partials/pages/contact.html'
      controller:   'ContactCtrl'
      noLogin:      yes
    .state 'login',
      url:          '/login'
      templateUrl:  '/partials/pages/login.html'
      controller:   'LoginCtrl'
      noLogin:      yes
    .state 'recover',
      url:          '/recover'
      templateUrl:  '/partials/pages/recover.html'
      controller:   'RecoverCtrl as recover'
      noLogin:      yes
    .state 'register',
      url:          '/register'
      templateUrl:  '/partials/pages/register.html'
      controller:   'RegisterCtrl as register'
      noLogin:      yes
    .state 'product',
      url:          '/product/:idProduct?screen'
      templateUrl:  '/partials/pages/product.html'
      controller:   'ProductCtrl as product'
      noLogin:      yes
    .state 'seller',
      url:          '/seller/:idUser'
      templateUrl:  '/partials/pages/seller.html'
      controller:   'SellerCtrl as seller'
      noLogin:      yes
    .state 'callback',
      url:          '/callback'
      templateUrl:  '/partials/pages/callback.html'
      controller:   'CallbackCtrl'
      noLogin:      yes
    $urlRouterProvider.otherwise ($injector) ->
      if $injector.get('MkmApiAuth').isLoggedIn() then '/home' else '/login'
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
      event.preventDefault() unless next.noLogin or MkmApiAuth.checkLogin()
    # new page, update view class and title
    $rootScope.$on '$stateChangeSuccess', (event, current) ->
      if current.name
        $rootScope.viewClass = current.name.split(".").shift()
        $rootScope.loggedIn = MkmApiAuth.isLoggedIn()
        $rootScope.username = MkmApiAuth.getUsername()
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
