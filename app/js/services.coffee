mkmobileServices = angular.module 'mkmobileServices', ['ngResource']

mkmobileServices.factory 'MkmApi', [ '$resource', '$location', 'DataCache',
($resource, $location, DataCache) ->
  ## helper functions
  parseRangeHeader = (headers) -> if headers().range? then parseInt(headers().range.replace(/^.*\//,''),10) else 0
  toXML = (obj, recursive = no) ->
    xml = ''
    if typeof obj is "object"
      for prop,val of obj
        if typeof val is "object"
          if val instanceof Array
            val = val.map((elem) -> toXML elem, yes).join "</#{prop}><#{prop}>"
          else
            val = toXML val, yes
        xml += "<#{prop}>#{val}</#{prop}>"
    else
      xml = obj
    xml = '<?xml version="1.0" encoding="UTF-8" ?><request>'+xml+'</request>' unless recursive
    xml
  ## variables
  auth =
    consumerKey: "alb03sLPpFNAhi6f"
    consumerSecret: "HTIcbso87X22JdS3Yk89c2CojfZiNDMX"
    token: sessionStorage.getItem("token") or ""
    secret: sessionStorage.getItem("secret") or ""
  redirectAfterLogin = "/"
  apiURL    = 'https://www.mkmapi.eu/ws'
  apiAuth   = '/bra1n/a042b2e17c5cba981d6f684ec338b98a'
  apiFormat = '/output.json'
  api       = $resource apiURL+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5', {},
    search:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: {type:"products",param2:"1",param3:"1",param4:"false"}
      unique: "search"
      oauth: auth
    articles:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: "articles"
      cache: no
      oauth: auth
    product:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: "product"
      oauth: auth
    access:
      method: 'POST'
      params: type: "access"
      headers: {'Content-type': 'application/xml'}
      oauth: auth
    cartUpdate:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      method: 'PUT'
      params: type: 'shoppingcart'
      headers: {'Content-type': 'application/xml'}
      oauth: auth
    shoppingcart:
      url: apiURL+apiAuth+apiFormat+'/:type/:param1/:param2/:param3/:param4/:param5' # deprecated
      params: type: 'shoppingcart'
      oauth: auth

  ## interface
  # search for a product
  search: (query, response) ->
    # if response isn't passed in, create a base object that will be filled later
    response = count: 0, products: [] unless response?
    if query
      # toggle loading flag
      response.loading = yes
      # query the API
      api.search {param1: query, param5: response.products.length + 1}, (data, headers) ->
        # cache products
        data.product?.map (val) -> DataCache.product val.idProduct, val
        # update count
        response.count = parseRangeHeader(headers) or data.product?.length
        # merge products
        response.products = response.products.concat data.product if response.count
        # toggle loading flag
        response.loading = no
    # return the base object
    response

  # get product data
  product: (id) ->
    response = product: DataCache.product id
    unless response.product? # no product data in cache, retrieve it!
      api.product param1: id, (data) ->
        response.product = DataCache.product id, data.product
    response

  # cart "class"
  cart:
    # get the cart object (optionally filtered by ID)
    # todo replace seller.username with idOrder
    get: (id, cb) ->
      response = cart: DataCache.cart()
      unless response.cart?
        # fetch the cart
        response.loading = yes
        api.shoppingcart {}, (data) ->
          response.loading = no
          response.cart = DataCache.cart data.shoppingCart
          response.cart = (order for order in response.cart when order.seller.username is id) if id?
          cb?(response)
      else
        # cart already there, yay!
        response.cart = (order for order in response.cart when order.seller.username is id) if id?
        cb?(response)
      response
    # get number of articles in cart
    count: ->
      if DataCache.cart()?
        # we have cart contents, calculate the count
        count = 0
        count += parseInt(seller.totalCount, 10) for seller in DataCache.cart()
        DataCache.cartCount count
      DataCache.cartCount()
    # get total sum of cart
    sum: ->
      sum = 0
      if DataCache.cart()?
        # we have cart contents, calculate the sum
        for seller in DataCache.cart()
          sum += seller.totalValue
      sum
    # add article to cart
    add: (article, cb) ->
      request =
        action: "add"
        article:
          idArticle: article
          amount: 1
      api.cartUpdate toXML(request), (data) ->
        console.log data
        DataCache.cart data.shoppingCart
        cb?()
    # remove article(s) from cart
    # to remove multiple ones, pass in idArticle as {id: amount, id2: amount2, etc.} object
    remove: (articles, cb) ->
      request = action: "remove"
      if typeof articles is "object"
        request.article = []
        request.article.push {idArticle, amount} for idArticle, amount of articles
      else
        request.article = {idArticle:articles, amount: 1}
      api.cartUpdate toXML(request), (data) ->
        DataCache.cart data.shoppingCart
        cb?()

  # get articles for a product
  articles: (id, response) ->
    response = count: 0, articles: [] unless response?
    response.loading = yes
    api.articles {param1: id, param2: response.articles.length + 1}, (data, headers) ->
      response.count = parseRangeHeader(headers) or data.article?.length
      response.articles = response.articles.concat data.article if response.count
      response.loading = no
    response

  # get login status
  isLoggedIn: -> auth.secret isnt ""

  # return login URL
  getLoginURL: -> apiURL + '/authenticate/' + auth.consumerKey

  # logout
  logout: ->
    auth.secret = auth.token = ""
    sessionStorage.removeItem "secret"
    sessionStorage.removeItem "token"
    $location.path '/login'

  # checks whether a user is logged in and redirects if necessary
  checkLogin: ->
    console.log "login check", @isLoggedIn()
    unless @isLoggedIn() and $location.path() isnt "/login"
      redirectAfterLogin = $location.path()
      $location.path '/login'

  # log the user in and store tokens in the session
  getAccess: (requestToken) ->
    response = {}
    auth.token = requestToken if requestToken?
    request =
      app_key: auth.consumerKey
      request_token: auth.token
    api.access toXML(request), (data) ->
      if data.oauth_token and data.oauth_token_secret
        auth.token = data.oauth_token
        auth.secret = data.oauth_token_secret
        sessionStorage.setItem "auth", auth.token
        sessionStorage.setItem "secret", auth.secret
        response.success = yes
        $location.path redirectAfterLogin
    , -> response.error = yes
    response = {}
]

mkmobileServices.factory 'DataCache', ['$cacheFactory', ($cacheFactory) ->
  # all glory to the mighty cache object
  cache =
    product: $cacheFactory 'products', capacity: 500
    article: $cacheFactory 'article', capacity: 100
    cart: $cacheFactory 'cart', capacity: 2
    user: $cacheFactory 'user', capacity: 1
  product: (id, data) ->
    cache.product.put(id, data) if data?
    cache.product.get(id) if id?
  article: (id, data) ->
    cache.article.put(id, data) if data?
    cache.article.get(id) if id?
  cart: (data) ->
    if data?
      # todo replace with API field for "total count per seller"
      for seller,index in data
        count = 0
        count += parseInt(article.count, 10) for article in seller.article
        data[index].totalCount = count
      # end of replace
      cache.cart.put('cart', data) if data?
    cache.cart.get('cart')
  cartCount: (count) ->
    cache.cart.put('count', count) if count?
    cache.cart.get('count') or 0
  user: (data) ->
    cache.user.put(1, data) if data?
    cache.user.get(1) or []
]