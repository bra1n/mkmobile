# /product
angular.module 'mkmobile.controllers.product', []
.controller 'ProductCtrl', [
  '$stateParams', 'MkmApiMarket', 'MkmApiAuth', 'MkmApiCart'
  ($stateParams, MkmApiMarket, MkmApiAuth, MkmApiCart) ->
    # get product data
    @productData = MkmApiMarket.product $stateParams.idProduct

    # load articles
    @data = MkmApiMarket.articles $stateParams.idProduct

    # infinite scrolling
    @loadArticles = =>
      return if @data.articles.length >= @data.count or @data.loading
      MkmApiMarket.articles $stateParams.idProduct, @data

    @addToCart = (article, event) =>
      event.stopPropagation()
      if MkmApiAuth.checkLogin()
        # reduce the amount before receiving the server response to prevent adding too many to the cart
        article.count--
        MkmApiCart.add article.idArticle
    @
]
