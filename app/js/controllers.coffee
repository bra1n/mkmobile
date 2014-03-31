mkmobileControllers = angular.module 'mkmobileControllers', []

# search for / or /login
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi', '$sce'
  ($scope, $routeParams, $location, MkmApi, $sce) ->
    MkmApi.checkLogin() if $location.path() is "/"
    $scope.search = -> $scope.searchData = MkmApi.search $scope.query
    $scope.updateHistory = -> $location.search search: $scope.query
    # init scope vars
    $scope.query = $routeParams.search
    $scope.search()
    $scope.sort = "name"

    # infinite scrolling
    $scope.loadResults = ->
      # don't load more if we already show all of them
      return if $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
      MkmApi.search $scope.query, $scope.searchData

    # handle login
    $scope.loggedIn = MkmApi.isLoggedIn()
    $scope.handleLogin = ->
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

    # bind cart count since it might change here
    $scope.cart = MkmApi.cart.count()

    # infinite scrolling
    $scope.loadArticles = ->
      return if $scope.data.articles.length >= $scope.data.count or $scope.data.loading
      MkmApi.articles $routeParams.productId, $scope.data

    $scope.addToCart = (article) ->
      MkmApi.checkLogin()
      MkmApi.cart.add article.idArticle, ->
        article.count--
        $scope.cart = MkmApi.cart.count()
]

# /settings
mkmobileControllers.controller 'SettingsCtrl', [
  '$scope', 'MkmApi'
  ($scope, MkmApi) ->
    MkmApi.checkLogin()
    $scope.vacation = false
    $scope.logout = -> MkmApi.logout()
]

# home page
mkmobileControllers.controller 'HomeCtrl', [
  '$scope', 'MkmApi', ($scope, MkmApi) ->
    MkmApi.checkLogin()
]

# /callback
mkmobileControllers.controller 'CallbackCtrl', [
  '$scope', '$location'
  ($scope, $location) ->
    search = $location.search()
    if search['request_token']?
      window.parent.handleCallback? search['request_token']
]

# /cart
mkmobileControllers.controller 'CartCtrl', [
  '$scope', '$location', '$routeParams', 'MkmApi'
  ($scope, $location, $routeParams, MkmApi) ->
    MkmApi.checkLogin()
    # search logic
    $scope.search = -> $scope.searchData = MkmApi.search $scope.query
    $scope.updateHistory = -> $location.search search: $scope.query
    $scope.loadResults = -> MkmApi.search($scope.query, $scope.searchData) unless $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
    $scope.query = $routeParams.search
    $scope.search()
    $scope.sort = "name"

    # load cart data
    $scope.data = MkmApi.cart.get $routeParams.orderId, (data) ->
      $scope.count = MkmApi.cart.count()
      $scope.sum = MkmApi.cart.sum()
      $location.path "/cart" if data.cart.length is 0 and $routeParams.orderId?
    # remove a single article
    $scope.removeArticle = (article) ->
      console.log "removing", article
      article.count-- # card count for this article
      $scope.count-- # total cart count
      newCount = --order.totalCount for order in $scope.data.cart when article in order.article # card count for this order
      MkmApi.cart.remove article.idArticle, ->
        if $routeParams.orderId? and !newCount
          $location.path "/cart"
        else
          $scope.data = MkmApi.cart.get $routeParams.orderId # should be updated now, no need for callback

    # remove a whole order
    $scope.removeOrder = (index) ->
      articles = {}
      articles[article.idArticle] = article.count for article in $scope.data.cart[index].article if $scope.data.cart[index]?
      $scope.data.cart.splice index, 1
      $scope.count = MkmApi.cart.count()
      $scope.sum = MkmApi.cart.sum()
      MkmApi.cart.remove articles

]