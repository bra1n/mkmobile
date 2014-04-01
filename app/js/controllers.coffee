mkmobileControllers = angular.module 'mkmobileControllers', []

# search for / or /login
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi', '$sce'
  ($scope, $routeParams, $location, MkmApi, $sce) ->
    MkmApi.auth.checkLogin() if $location.path() is "/"
    $scope.search = -> $scope.searchData = MkmApi.market.search $scope.query
    $scope.updateHistory = -> $location.search search: $scope.query
    # init scope vars
    $scope.query = $routeParams.search
    $scope.search()
    $scope.sort = "name"

    # infinite scrolling
    $scope.loadResults = ->
      # don't load more if we already show all of them
      return if $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
      MkmApi.market.search $scope.query, $scope.searchData

    # handle login
    $scope.loggedIn = MkmApi.auth.isLoggedIn()
    $scope.handleLogin = ->
      $scope.iframeSrc = $sce.trustAsResourceUrl MkmApi.auth.getLoginURL()
      window.handleCallback = (token) ->
        $scope.iframeSrc = null
        $scope.login = MkmApi.auth.getAccess token
        delete window.handleCallback
    $scope.logout = ->
      MkmApi.auth.logout()
      $scope.loggedIn = no
]

# /product
mkmobileControllers.controller 'ProductCtrl', [
  '$scope', '$routeParams', 'MkmApi'
  ($scope, $routeParams, MkmApi) ->
    # get product data
    $scope.productData = MkmApi.market.product $routeParams.productId

    # load articles
    $scope.data = MkmApi.market.articles $routeParams.productId

    # bind cart count since it might change here
    $scope.cart = MkmApi.cart.count()

    # infinite scrolling
    $scope.loadArticles = ->
      return if $scope.data.articles.length >= $scope.data.count or $scope.data.loading
      MkmApi.market.articles $routeParams.productId, $scope.data

    $scope.addToCart = (article) ->
      MkmApi.auth.checkLogin()
      MkmApi.cart.add article.idArticle, ->
        article.count--
        $scope.cart = MkmApi.cart.count()
]

# /settings
mkmobileControllers.controller 'SettingsCtrl', [
  '$scope', 'MkmApi', '$location'
  ($scope, MkmApi, $location) ->
    MkmApi.auth.checkLogin()
    $scope.vacation = false
    $scope.logout = -> MkmApi.auth.logout()
]

# home page
mkmobileControllers.controller 'HomeCtrl', [
  '$scope', 'MkmApi', ($scope, MkmApi) ->
    MkmApi.auth.checkLogin()
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
    MkmApi.auth.checkLogin()
    # search logic
    $scope.search = -> $scope.searchData = MkmApi.market.search $scope.query
    $scope.updateHistory = -> $location.search search: $scope.query
    $scope.loadResults = ->
      unless $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
        MkmApi.market.search($scope.query, $scope.searchData)
    $scope.query = $routeParams.search
    $scope.search()
    $scope.sort = "name"

    # load cart data
    $scope.data = MkmApi.cart.get $routeParams.orderId, (data) ->
      $scope.count = MkmApi.cart.count()
      $scope.sum = MkmApi.cart.sum()
      $location.path "/cart" if data.cart.length is 0 and $routeParams.orderId?
    # remove a single article
    $scope.removeArticle = (article, order) ->
      console.log "removing", article
      article.count-- # card count for this article
      $scope.count-- # total cart count
      order.totalCount-- # reduce total order count
      MkmApi.cart.remove article.idArticle, ->
        if $routeParams.orderId? and !order.totalCount
          $location.path "/cart"
        else
          $scope.data = MkmApi.cart.get $routeParams.orderId # should be updated now, no need for callback

    # remove a whole order
    $scope.removeOrder = (order) ->
      articles = {}
      articles[article.idArticle] = article.count for article in order.article if order.article?
      $scope.data.cart.splice $scope.data.cart.indexOf(order), 1
      $scope.count = MkmApi.cart.count()
      $scope.sum = MkmApi.cart.sum()
      MkmApi.cart.remove articles

]

# /stock
mkmobileControllers.controller 'StockCtrl', [
  '$scope', '$location', '$routeParams', 'MkmApi'
  ($scope, $location, $routeParams, MkmApi) ->
    MkmApi.auth.checkLogin()
    $scope.data = MkmApi.stock.get $routeParams.articleId
    $scope.selected = []
    $scope.select = (id) ->
      if id in $scope.selected
        $scope.selected.splice $scope.selected.indexOf(id), 1
      else
        $scope.selected.push id
    $scope.loadArticles = ->
      return if $scope.data.articles.length >= $scope.data.count or $scope.data.loading
      MkmApi.stock.get $routeParams.articleId, $scope.data
    $scope.search = ->
      console.log $scope.query
    # edit article stuff
    $scope.languages = {1:"EN",2:"FR",3:"DE",4:"SP",5:"IT",6:"CH",7:"JP",8:"PT",9:"RU",10:"KO",11:"TW"}
    $scope.conditions = ["MT","NM","EX","GD","LP","PL","PO"]
    $scope.save = -> MkmApi.stock.update $scope.data.article, -> $location.path "/stock"
]