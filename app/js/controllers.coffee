mkmobileControllers = angular.module 'mkmobileControllers', []

mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi'
  ($scope, $routeParams, $location, MkmApi) ->
    $scope.search = ->
      $location.search query: $scope.query
      MkmApi.search search:$scope.query, (data) ->
        return unless data?.product?
        $scope.products = []
        $scope.products.push product for product in [].concat(data.product) when product.category.idCategory is "1"
    $scope.query = $routeParams.query
    $scope.search() if $scope.query
    $scope.sort = "name"
]

mkmobileControllers.controller 'ProductCtrl', [
  '$scope', '$routeParams', 'MkmApi'
  ($scope, $routeParams, MkmApi) ->
    $scope.productId = $routeParams.productId
    MkmApi.articles articles: $routeParams.productId, (data) ->
      return unless data?.article?
      $scope.articles = []
      $scope.articles.push article for article in [].concat(data.article)
]