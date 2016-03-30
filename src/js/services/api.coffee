angular.module 'mkmobile.services.api', ['ngResource']
.factory 'MkmApi', [ '$resource', ($resource) ->
  sessionAuth = JSON.parse(sessionStorage.getItem('auth')) or {}
  auth =
    consumerKey:    window.consumerKey or 'alb03sLPpFNAhi6f'
    consumerSecret: window.consumerSecret or 'HTIcbso87X22JdS3Yk89c2CojfZiNDMX'
    secret:         window.accessSecret or sessionAuth.secret or ''
    token:          window.accessToken or sessionAuth.token or ''
    username:       window.username or sessionAuth.username or ''
  apiURL    = 'https://sandbox.mkmapi.eu/ws/v2.0'
  apiParams =
    # Misc
    access: # exchange temporary token with access token, get user details
      params: param0: 'access'
      method: 'POST'
    contact:
      params: param0: 'support'
      method: 'POST'
    captcha:
      params: param0: 'captcha'

    # Marketplace
    search: # search for a product
      params: {param0:'products', param1:'find', idGame:window.gameId or '1', idLanguage:'1'}
      unique: 'search'
      cache:  yes
    articles: # get all articles for a product
      params: param0: 'articles'
    product: # get a single product
      params: param0: 'products'
      cache: yes
    users: # search for a user
      params: {param0: 'users', param1: 'find'}
      cache: yes
      unique: 'user'
    user: # get a single user
      params: {param0: 'users'}
      cache: yes

    # Shopping Cart
    cart: # get shoppingcart contents
      params: param0: 'shoppingcart'
    cartUpdate: # update shoppingcart contents
      params: param0: 'shoppingcart'
      method: 'PUT'
    cartEmpty: # empty the shoppingcart
      params: param0: 'shoppingcart'
      method: 'DELETE'
    shippingAddress: # update shipping address for shoppingcart
      params: {param0: 'shoppingcart', param1: 'shippingaddress'}
      method: 'PUT'
    shippingMethod: # get shipping methods for order
      params: {param0: 'shoppingcart', param1: 'shippingmethod'}
    shippingMethodUpdate: # change shipping methods for order
      params: {param0: 'shoppingcart', param1: 'shippingmethod', param2: '@idOrder'}
      method: 'PUT'
    checkout: # checkout shoppingcart
      params: {param0: 'shoppingcart', param2: 'checkout'}
      method: 'PUT'

    stock: # get stock articles
      params: param0: 'stock'
    stockSearch: # search stock
      params: {param0: 'stock', param1: 'articles', param3: window.gameId or '1'}
      unique: 'searchStock'
    stockUpdate: # update stock articles
      params: {param0: 'stock', param1: '@action'}
      method: 'PUT'
    stockCreate: # create a stock article
      params: {param0: 'stock'}
      method: 'POST'

    orders: # get buys / sells
      params: param0: 'orders'
      unique: 'order'
    order: # get a single order
      params: param0: 'order'
    orderUpdate: # update an order (status)
      params: param0: 'order'
      method: 'PUT'
    orderEvaluate: # evaluate an order
      params: {param0: 'order', param1: '@idOrder', param2: 'evaluation'}
      method: 'POST'

    # Account Management
    account: # get account data
      params: param0: 'account'
    accountVacation: # change vacation flag for account
      params: {param0: 'account', param1: 'vacation', onVacation: '@vacation'}
      method: 'PUT'
    accountLanguage: # update account language
      params: {param0: 'account', param1: 'language', idDisplayLanguage: '@languageId'}
      method: 'PUT'
    accountLogindata: # recover logindata
      params: {param0: 'account', param1: 'logindata', type: '@type'}
      method: 'POST'
    accountRegister: # register new account
      params: {param0: 'account', param1: 'registration'}
      method: 'POST'
    accountCoupon: # redeem coupon
      params: {param0: 'account', param1: 'coupon'}
      method: 'POST'

    messages: # get all messages
      params: {param0: 'account', param1: 'messages'}
    messageSend: # send a message
      params: {param0: 'account', param1: 'messages', param2: '@param2'}
      method: 'POST'
    messageDelete: #delete a message (thread)
      params: {param0: 'account', param1: 'messages'}
      method: 'DELETE'
  # augment the configs
  for param,config of apiParams
    # oauth for all the requests
    apiParams[param].oauth = auth
    # PUT / POST should send the right content-type header
    apiParams[param].headers = {'Content-type': 'application/xml'} if config.method in ['PUT', 'POST']
  api: $resource apiURL+'/output.json/:param0/:param1/:param2/:param3/:param4/:param5', {}, apiParams
  auth: auth
  url: apiURL+'/authenticate/'
]
