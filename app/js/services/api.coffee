mkmobileServices.factory 'MkmApi', [ '$resource', ($resource) ->
  auth =
    consumerKey:    'alb03sLPpFNAhi6f'
    consumerSecret: 'HTIcbso87X22JdS3Yk89c2CojfZiNDMX'
    token:          sessionStorage.getItem('token') or ''
    secret:         sessionStorage.getItem('secret') or ''
  apiURL    = 'https://sandbox.mkmapi.eu/ws/v1.1'
  apiFormat = '/output.json'
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

    shoppingcart: # get shoppingcart contents
      params: type: 'shoppingcart'
    cartUpdate: # update shoppingcart contents
      params: type: 'shoppingcart'
      method: 'PUT'
    shippingAddress: # update shipping address for shoppingcart
      params: {type: 'shoppingcart', param1: 'shippingaddress'}
      method: 'PUT'
    checkout: # checkout shoppingcart
      params: {type: 'shoppingcart', param2: 'checkout'}

    stock: # get stock articles
      params: type: 'stock'
    stockSearch: # search stock
      params: {type: 'stock', param1: 'articles', param3: '1'}
    stockUpdate: # update stock articles
      params: type: 'stock'
      method: 'PUT'
    stockAmount: # change stock article amount
      params: {type: 'stock', param1: 'article', param2: '@param2', param3: '@param3', param4: '@param4'}
      method: 'PUT'

    orders: # get buys / sells
      params: type: 'orders'
      unique: 'order'
    order: # get a single order
      params: type: 'order'
    orderUpdate: # update an order (status)
      params: type: 'order'
      method: 'PUT'

    account: # get account data
      params: type: 'account'
    accountVacation: # change vacation flag for account
      params: {type: 'account', param1: 'vacation', param2: '@param2'}
      method: 'PUT'

    messages: # get all messages
      params: {type: 'account', param1: 'messages'}
  # augment the configs
  for param,config of apiParams
    # oauth for all the requests
    apiParams[param].oauth = auth
    # PUT / POST should send the right content-type header
    apiParams[param].headers = {'Content-type': 'application/xml'} if config.method in ['PUT', 'POST']
  api: $resource apiURL+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5', {}, apiParams
  auth: auth
  url: apiURL+'/authenticate/'
]