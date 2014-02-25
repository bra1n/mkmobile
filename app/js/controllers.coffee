mkmobileControllers = angular.module 'mkmobileControllers', []

# /search
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi', 'DataCache'
  ($scope, $routeParams, $location, MkmApi, DataCache) ->
    $scope.search = ->
      $location.search query: $scope.query
      MkmApi.search param1:$scope.query, (data) ->
        return unless data?.product?
        $scope.products = []
        for product in [].concat(data.product) when product.category?.idCategory is "1"
          $scope.products.push DataCache.product product.idProduct, product
    $scope.query = $routeParams.query
    $scope.search() if $scope.query
    $scope.sort = "name"
]

# /product
mkmobileControllers.controller 'ProductCtrl', [
  '$scope', '$routeParams', 'MkmApi', 'DataCache'
  ($scope, $routeParams, MkmApi, DataCache) ->
    # get product data
    $scope.product = DataCache.product $routeParams.productId
    unless $scope.product? # no product data in cache, retrieve it!
      MkmApi.product param1: $routeParams.productId, (data) ->
        $scope.product = DataCache.product $routeParams.productId, data.product

    # load articles
    $scope.data = MkmApi.articles param1: $routeParams.productId

    # infinite scrolling
    $scope.loadArticles = ->
      # don't load more if we already show all of them
      return unless $scope.data?.count > 100 and $scope.data.article.length < $scope.data.count
      # don't load more if there already is a request running
      return if $scope.running?
      $scope.running = MkmApi.articles {param1: $routeParams.productId, param2:$scope.data.article.length + 1}, (data) ->
        $scope.running = null
        $scope.data.article = $scope.data.article.concat data.article
]