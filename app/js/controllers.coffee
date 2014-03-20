mkmobileControllers = angular.module 'mkmobileControllers', []

# search for / or /login
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi', '$sce'
  ($scope, $routeParams, $location, MkmApi, $sce) ->
    MkmApi.checkLogin() if $location.path() is "/"
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
    $scope.loggedIn = MkmApi.isLoggedIn()
    $scope.login = ->
      $scope.iframeSrc = $sce.trustAsResourceUrl MkmApi.getLoginURL()
      window.handleCallback = (token) ->
        $scope.iframeSrc = null
        $scope.login = MkmApi.getAccess token
        delete window.handleCallback
    $scope.logout = ->
      MkmApi.logout()
      $scope.loggedIn = no
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
      MkmApi.checkLogin()
      console.log "add", article.idArticle
      article.count--

]

# /callback
mkmobileControllers.controller 'CallbackCtrl', [
  '$scope', '$location'
  ($scope, $location) ->
    search = $location.search()
    if search['request_token']?
      window.parent.handleCallback? search['request_token']
]
