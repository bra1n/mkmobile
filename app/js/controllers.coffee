mkmobileControllers = angular.module 'mkmobileControllers', []

# /search
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi', 'DataCache'
  ($scope, $routeParams, $location, MkmApi, DataCache) ->
    $scope.search = ->
      # update URL to match what is entered
      $location.search search: $scope.query
      return unless $scope.query
      # fetch the data
      $scope.running = MkmApi.search param1:$scope.query, (data, headers) ->
        $scope.data = data
        $scope.running = null
        # cache products
        data.product?.map (val) -> DataCache.product val.idProduct, val
        # update count
        console.log headers()
        $scope.count = if headers().range? then headers().range.replace /^.*\//,'' else $scope.data.product?.length or 0
        $scope.data.product = [] unless $scope.count
    # init scope vars
    $scope.count = 0
    $scope.query = $routeParams.search
    $scope.search()
    $scope.sort = "name"

    # infinite scrolling
    $scope.loadResults = ->
      # don't load more if we already show all of them
      return unless $scope.count > 100 and $scope.data.product.length < $scope.count
      # don't load more if there already is a request running
      return if $scope.running?
      $scope.running = MkmApi.search {param1:$scope.query, param5:$scope.data.product.length + 1}, (data) ->
        $scope.running = null
        $scope.data.product = $scope.data.product.concat data.product?.map (val) -> DataCache.product val.idProduct, val
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
    $scope.data = MkmApi.articles param1: $routeParams.productId, (data, headers) ->
      $scope.count = if headers().range? then headers().range.replace /^.*\//,'' else data.article?.length or 0

    # infinite scrolling
    $scope.loadArticles = ->
      # don't load more if we already show all of them
      return unless $scope.count > 100 and $scope.data.article.length < $scope.count
      # don't load more if there already is a request running
      return if $scope.running?
      $scope.running = MkmApi.articles {param1:$routeParams.productId, param2:$scope.data.article.length + 1}, (data) ->
        $scope.running = null
        $scope.data.article = $scope.data.article.concat data.article
]