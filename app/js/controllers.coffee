mkmobileControllers = angular.module 'mkmobileControllers', []

# /search
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi', '$sce'
  ($scope, $routeParams, $location, MkmApi, $sce) ->
    $scope.search = -> $scope.data = MkmApi.search $scope.query
    $scope.updateHistory = -> $location.search search: $scope.query
    # init scope vars
    $scope.query = $routeParams.search
    $scope.search()
    $scope.sort = "name"

    # infinite scrolling
    $scope.loadResults = ->
      # don't load more if we already show all of them
      return if $scope.data.products.length >= $scope.data.count or $scope.data.loading
      MkmApi.search $scope.query, $scope.data

    # handle login
    $scope.login = ->
      console.log "logging in"
      $scope.iframeSrc = $sce.trustAsResourceUrl MkmApi.getLoginURL()
      #MkmApi.login()
]

# /product
mkmobileControllers.controller 'ProductCtrl', [
  '$scope', '$routeParams', 'MkmApi'
  ($scope, $routeParams, MkmApi) ->
    # get product data
    $scope.productData = MkmApi.product $routeParams.productId

    # load articles
    $scope.data = MkmApi.articles $routeParams.productId

    # infinite scrolling
    $scope.loadArticles = ->
      return if $scope.data.articles.length >= $scope.data.count or $scope.data.loading
      MkmApi.articles $routeParams.productId, $scope.data

    $scope.addToCart = (article) ->
      return unless MkmApi.isLoggedIn()
      console.log "add", article.idArticle
      article.count--

]

# /callback
mkmobileControllers.controller 'CallbackCtrl', [
  '$scope', '$location', 'MkmApi'
  ($scope, $location, MkmApi) ->
    search = $location.search()
    if search.request_token?
      MkmApi.getAccess search.request_token
]