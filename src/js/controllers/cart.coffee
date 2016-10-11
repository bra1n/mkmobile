# /cart
angular.module 'mkmobile.controllers.cart', []
.controller 'CartCtrl', ($scope, $location, $stateParams, MkmApiCart, MkmApiMarket, $translate) ->
  # load cart data
  $scope.data = MkmApiCart.get $stateParams.orderId, ->
    $scope.count = MkmApiCart.count()
    $scope.sum = MkmApiCart.sum()
    if $scope.count is 0 and ($stateParams.orderId? or $stateParams.method?)
      $location.path("/cart").replace()

  # remove a single article
  $scope.removeArticle = (article, order) ->
    article.count-- # card count for this article
    $scope.count-- # total cart count
    order.articleCount-- # reduce total order count
    order.totalValue -= article.price # reduce total order count
    MkmApiCart.remove article.idArticle, ->
      if $stateParams.orderId? and !order.articleCount
        $location.path("/cart").replace()
      else
        $scope.data = MkmApiCart.get $stateParams.orderId # should be updated now, no need for callback

  # remove a whole order
  $scope.removeOrder = (order) ->
    articles = {}
    articles[article.idArticle] = article.count for article in order.article if order.article?
    $scope.data.cart.splice $scope.data.cart.indexOf(order), 1
    MkmApiCart.remove articles, ->
      $scope.count = MkmApiCart.count()
      $scope.sum = MkmApiCart.sum()
      $scope.data = MkmApiCart.get $stateParams.orderId # should be updated now, no need for callback

  # empty the shopping cart
  $scope.emptyCart = ->
    $scope.data.cart = []
    $scope.count =  $scope.sum = 0
    MkmApiCart.empty()

  # change shipping address
  $scope.countries = MkmApiCart.getCountries()
  $scope.shippingAddress = (address) -> MkmApiCart.shippingAddress address, -> $location.path '/cart'

  # change shipping method
  $scope.shippingMethod = (order) -> MkmApiCart.shippingMethod order

  # checkout
  $scope.method = $stateParams.method
  $scope.checkout = -> $translate('checkout.are_you_sure').then (text) ->
    return unless confirm text
    $scope.clicked = yes
    MkmApiCart.checkout ->
      try sessionStorage.setItem 'buysTab', (if $scope.method is 'instabuy' then 'paid' else 'bought')
      $location.path switch $scope.method
        when 'paypal' then '/payment/paypal'
        when 'bank' then '/payment/bank'
        else '/buys'
