# /product
angular.module 'mkmobile.controllers.product', []
.controller 'ProductCtrl', [
  '$stateParams', '$state', 'MkmApiMarket', 'MkmApiAuth', 'MkmApiCart', 'MkmApiStock'
  ($stateParams, $state, MkmApiMarket, MkmApiAuth, MkmApiCart, MkmApiStock) ->
    # init vars
    @screen = $stateParams.screen
    @languages = MkmApiStock.getLanguages()
    @conditions = MkmApiStock.getConditions()

    # get product data
    @productData = MkmApiMarket.product $stateParams.idProduct

    # load articles
    @data = MkmApiMarket.articles $stateParams.idProduct

    # infinite scrolling
    @loadArticles = =>
      return if @data.articles.length >= @data.count or @data.loading
      MkmApiMarket.articles $stateParams.idProduct, @data

    # show overlay
    @show = (screen, event) =>
      event.preventDefault() if @screen and event
      @screen = if @screen is screen then "" else screen
      $stateParams.screen = @screen
      $state.transitionTo $state.current.name, $stateParams, {notify: no, location: 'replace'}

    # add article to cart
    @addToCart = (article, event) =>
      event.stopPropagation()
      if MkmApiAuth.checkLogin()
        # reduce the amount before receiving the server response to prevent adding too many to the cart
        article.count--
        MkmApiCart.add article.idArticle
    @
]
