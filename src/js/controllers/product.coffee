# /product
angular.module 'mkmobile.controllers.product', []
.controller 'ProductCtrl', [
  '$scope', '$routeParams', 'MkmApiMarket', 'MkmApiCart', 'MkmApiAuth'
  ($scope, $routeParams, MkmApiMarket, MkmApiCart, MkmApiAuth) ->
    # get product data
    $scope.productData = MkmApiMarket.product $routeParams.productId

    # load articles
    $scope.data = MkmApiMarket.articles $routeParams.productId

    # bind cart count since it might change here
    $scope.cart = MkmApiCart.count()

    # infinite scrolling
    $scope.loadArticles = ->
      return if $scope.data.articles.length >= $scope.data.count or $scope.data.loading
      MkmApiMarket.articles $routeParams.productId, $scope.data

    $scope.addToCart = (article) ->
      if MkmApiAuth.checkLogin()
        # reduce the amount before receiving the server response to prevent adding too many to the cart
        article.count--
        MkmApiCart.add article.idArticle, ->
          $scope.cart = MkmApiCart.count()
]
