mkmobileServices.factory 'MkmApi', [ '$resource', ($resource) ->
  auth =
    consumerKey:    'alb03sLPpFNAhi6f'
    consumerSecret: 'HTIcbso87X22JdS3Yk89c2CojfZiNDMX'
    token:          sessionStorage.getItem('token') or ''
    secret:         sessionStorage.getItem('secret') or ''
  apiURL    = 'https://sandbox.mkmapi.eu/ws/v1.1'
  apiParams =
    search: # search for a product
      params: {type:'products',param2:'1',param3:'1',param4:'false'}
      unique: 'search'
      cache:  yes
    articles: # get all articles for a product
      params: type: 'articles'
    product: # get a single product
      params: type: 'product'
      cache: yes
    access: # exchange temporary token with access token, get user details
      params: type: 'access'
      method: 'POST'

    cart: # get shoppingcart contents
      params: type: 'shoppingcart'
    cartUpdate: # update shoppingcart contents
      params: type: 'shoppingcart'
      method: 'PUT'
    shippingAddress: # update shipping address for shoppingcart
      params: {type: 'shoppingcart', param1: 'shippingaddress'}
      method: 'PUT'
    shippingMethod: # get shipping methods for order
      params: {type: 'shoppingcart', param1: 'shippingmethod'}
    shippingMethodUpdate: # change shipping methods for order
      params: {type: 'shoppingcart', param1: 'shippingmethod', param2: '@orderId'}
      method: 'PUT'
    checkout: # checkout shoppingcart
      params: {type: 'shoppingcart', param2: 'checkout'}

    stock: # get stock articles
      params: type: 'stock'
    stockSearch: # search stock
      params: {type: 'stock', param1: 'articles', param3: '1'}
      unique: 'searchStock'
    stockUpdate: # update stock articles
      params: {type: 'stock', param1: '@action'}
      method: 'PUT'

    orders: # get buys / sells
      params: type: 'orders'
      unique: 'order'
    order: # get a single order
      params: type: 'order'
    orderUpdate: # update an order (status)
      params: type: 'order'
      method: 'PUT'
    orderEvaluate: # evaluate an order
      params: {type: 'order', param1: '@orderId', param2: 'evaluation'}
      method: 'POST'

    account: # get account data
      params: type: 'account'
    accountVacation: # change vacation flag for account
      params: {type: 'account', param1: 'vacation', param2: '@param2'}
      method: 'PUT'

    messages: # get all messages
      params: {type: 'account', param1: 'messages'}
    messageSend: # send a message
      params: {type: 'account', param1: 'messages', param2: '@param2'}
      method: 'POST'
  # augment the configs
  for param,config of apiParams
    # oauth for all the requests
    apiParams[param].oauth = auth
    # PUT / POST should send the right content-type header
    apiParams[param].headers = {'Content-type': 'application/xml'} if config.method in ['PUT', 'POST']
  api: $resource apiURL+'/output.json/:type/:param1/:param2/:param3/:param4/:param5', {}, apiParams
  auth: auth
  url: apiURL+'/authenticate/'
]