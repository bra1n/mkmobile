mkmobileServices.factory 'MkmApiCart', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  # get the cart object (optionally filtered by ID)
  # todo replace seller.username with idOrder
  get: (id, cb) ->
    response = cart: DataCache.cart()
    unless response.cart?
      # fetch the cart
      response.loading = yes
      MkmApi.api.shoppingcart {}, (data) =>
        response.loading = no
        response.cart = DataCache.cart data.shoppingCart
        response.order = (order for order in response.cart when order.seller.username is id) if id?
        cb?(response)
    else
      # cart already there, yay!
      response.order = (order for order in response.cart when order.seller.username is id) if id?
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
    MkmApi.api.cartUpdate request, (data) =>
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
    MkmApi.api.cartUpdate request, (data) =>
      DataCache.cart data.shoppingCart
      cb?()
]