mkmobileControllers = angular.module 'mkmobileControllers', []

# /search
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi', 'DataCache'
  ($scope, $routeParams, $location, MkmApi, DataCache) ->
    $scope.search = ->
      $scope.status = "loading"
      $location.search query: $scope.query
      MkmApi.search param1:$scope.query, (data) ->
        $scope.status = ""
        return unless data?.product?
        $scope.products = []
        for product in [].concat(data.product) when product.category.idCategory is "1"
          $scope.products.push DataCache.product product.idProduct, product
    $scope.query = $routeParams.query
    $scope.search() if $scope.query
    $scope.sort = "name"
]

# /product
mkmobileControllers.controller 'ProductCtrl', [
  '$scope', '$routeParams', 'MkmApi', 'DataCache'
  ($scope, $routeParams, MkmApi, DataCache) ->
    $scope.productId = $routeParams.productId
    $scope.product = DataCache.product $scope.productId
    $scope.status = "loading"
    unless $scope.product? # no product data in cache, retrieve it!
      MkmApi.product param1: $routeParams.productId, (data) ->
        $scope.product = DataCache.product $routeParams.productId, data.product
    MkmApi.articles param1: $routeParams.productId, (data) ->
      $scope.status = ""
      return unless data?.article?
      $scope.articles = []
      $scope.articles.push article for article in [].concat(data.article)
]