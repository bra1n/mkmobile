# /product
angular.module 'mkmobile.controllers.product', []
.controller 'ProductCtrl', [
  '$scope', '$stateParams', 'MkmApiMarket', 'MkmApiCart', 'MkmApiAuth'
  ($scope, $stateParams, MkmApiMarket, MkmApiCart, MkmApiAuth) ->
    # get product data
    $scope.productData = MkmApiMarket.product $stateParams.idProduct

    # load articles
    $scope.data = MkmApiMarket.articles $stateParams.idProduct

    # bind cart count since it might change here
    $scope.cart = MkmApiCart.count()

    # infinite scrolling
    $scope.loadArticles = ->
      return if $scope.data.articles.length >= $scope.data.count or $scope.data.loading
      MkmApiMarket.articles $stateParams.idProduct, $scope.data

    $scope.addToCart = (article) ->
      if MkmApiAuth.checkLogin()
        # reduce the amount before receiving the server response to prevent adding too many to the cart
        article.count--
        MkmApiCart.add article.idArticle, ->
          $scope.cart = MkmApiCart.count()
]
