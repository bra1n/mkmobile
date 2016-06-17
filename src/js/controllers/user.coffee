# /seller
angular.module 'mkmobile.controllers.user', []
.controller 'UserCtrl', [
  '$stateParams', 'MkmApiMarket', 'MkmApiAuth', 'MkmApiCart'
  ($stateParams, MkmApiMarket, MkmApiAuth, MkmApiCart) ->
    @username = MkmApiAuth.getUsername()
    @seller = MkmApiMarket.getUser $stateParams.idUser
    @data = MkmApiMarket.getUserArticles $stateParams.idUser

    # infinite scrolling
    @loadArticles = =>
      return if @data.articles.length >= @data.count or @data.loading
      MkmApiMarket.getUserArticles $stateParams.idUser, @data

    # add article to cart
    @addToCart = (article, event) =>
      event.stopPropagation()
      if MkmApiAuth.checkLogin()
        # reduce the amount before receiving the server response to prevent adding too many to the cart
        article.count--
        MkmApiCart.add article.idArticle
    @
]
