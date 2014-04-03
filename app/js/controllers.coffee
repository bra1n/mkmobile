# search for / or /login
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApiAuth', 'MkmApiMarket', '$sce'
  ($scope, $routeParams, $location, MkmApiAuth, MkmApiMarket, $sce) ->
    $scope.search = -> $scope.searchData = MkmApiMarket.search $scope.query
    $scope.updateHistory = -> $location.search search: $scope.query
    # init scope vars
    $scope.query = $routeParams.search
    $scope.search()
    $scope.sort = "name"

    # infinite scrolling
    $scope.loadResults = ->
      # don't load more if we already show all of them
      return if $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
      MkmApiMarket.search $scope.query, $scope.searchData

    # handle login
    $scope.loggedIn = MkmApiAuth.isLoggedIn()
    $scope.handleLogin = ->
      $scope.iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()
      window.handleCallback = (token) ->
        $scope.iframeSrc = null
        $scope.login = MkmApiAuth.getAccess token
        delete window.handleCallback
    $scope.logout = ->
      MkmApiAuth.logout()
      $scope.loggedIn = no
]

# /product
mkmobileControllers.controller 'ProductCtrl', [
  '$scope', '$routeParams', 'MkmApiMarket', 'MkmApiCart', 'MkmApiAuth'
  ($scope, $routeParams, MkmApiMarket, MkmApiCart, MkmApiAuth) ->
    # get product data
    $scope.productData = MkmApiMarket.product $routeParams.productId

    # load articles
    $scope.data = MkmApiMarket.articles $routeParams.productId

    # bind cart count since it might change here
    $scope.cart = MkmApiCart.count()

    # infinite scrolling
    $scope.loadArticles = ->
      return if $scope.data.articles.length >= $scope.data.count or $scope.data.loading
      MkmApiMarket.articles $routeParams.productId, $scope.data

    $scope.addToCart = (article) ->
      if MkmApiAuth.checkLogin()
        MkmApiCart.add article.idArticle, ->
          article.count--
          $scope.cart = MkmApiCart.count()
]

# /settings
mkmobileControllers.controller 'SettingsCtrl', [
  '$scope', 'MkmApiAuth'
  ($scope, MkmApiAuth) ->
    $scope.vacation = false
    $scope.logout = -> MkmApiAuth.logout()
]

# home page
mkmobileControllers.controller 'HomeCtrl', [
  '$scope', ($scope) ->
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
  '$scope', '$location', '$routeParams', 'MkmApiCart', 'MkmApiMarket'
  ($scope, $location, $routeParams, MkmApiCart, MkmApiMarket) ->
    # search logic
    $scope.search = -> $scope.searchData = MkmApiMarket.search $scope.query
    $scope.updateHistory = -> $location.search search: $scope.query
    $scope.loadResults = ->
      unless $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
        MkmApiMarket.search($scope.query, $scope.searchData)
    $scope.query = $routeParams.search
    $scope.search()
    $scope.sort = "name"

    # load cart data
    $scope.data = MkmApiCart.get $routeParams.orderId, (data) ->
      $scope.count = MkmApiCart.count()
      $scope.sum = MkmApiCart.sum()
      $location.path "/cart" if data.cart.length is 0 and $routeParams.orderId?
    # remove a single article
    $scope.removeArticle = (article, order) ->
      console.log "removing", article
      article.count-- # card count for this article
      $scope.count-- # total cart count
      order.totalCount-- # reduce total order count
      MkmApiCart.remove article.idArticle, ->
        if $routeParams.orderId? and !order.totalCount
          $location.path "/cart"
        else
          $scope.data = MkmApiCart.get $routeParams.orderId # should be updated now, no need for callback

    # remove a whole order
    $scope.removeOrder = (order) ->
      articles = {}
      articles[article.idArticle] = article.count for article in order.article if order.article?
      $scope.data.cart.splice $scope.data.cart.indexOf(order), 1
      $scope.count = MkmApiCart.count()
      $scope.sum = MkmApiCart.sum()
      MkmApiCart.remove articles

]

# /stock
mkmobileControllers.controller 'StockCtrl', [
  '$scope', '$location', '$routeParams', 'MkmApiStock'
  ($scope, $location, $routeParams, MkmApiStock) ->
    $scope.data = MkmApiStock.get $routeParams.articleId
    $scope.selected = []
    $scope.select = (id) ->
      if id in $scope.selected
        $scope.selected.splice $scope.selected.indexOf(id), 1
      else
        $scope.selected.push id
    $scope.loadArticles = ->
      return if $scope.data.articles.length >= $scope.data.count or $scope.data.loading
      MkmApiStock.get $routeParams.articleId, $scope.data
    $scope.search = ->
      console.log $scope.query
    $scope.increase = (articles) ->
      for article in articles
        MkmApiStock.increase article, -> article.count++
    $scope.decrease = (articles) ->
      for article in articles
        MkmApiStock.decrease article, -> article.count--
    # edit article stuff
    $scope.languages = {1:"EN",2:"FR",3:"DE",4:"SP",5:"IT",6:"CH",7:"JP",8:"PT",9:"RU",10:"KO",11:"TW"}
    $scope.conditions = ["MT","NM","EX","GD","LP","PL","PO"]
    $scope.save = -> MkmApiStock.update $scope.data.article, -> $location.path "/stock"
]

# /buys /sells
mkmobileControllers.controller 'OrderCtrl', [
  '$scope', '$location', '$routeParams', 'MkmApiOrder'
  ($scope, $location, $routeParams, MkmApiOrder) ->
    $scope.mode = $location.path().substr(1).replace /^(.*?)\/.*?$/, '$1'
    $scope.orderId = $routeParams.orderId
    $scope.$watch "tab", (status) ->
      $location.search(tab: status) unless $scope.orderId?
      $scope.data = MkmApiOrder.get {mode: $scope.mode, status, orderId: $scope.orderId}
    $scope.tab = $location.search().tab or "bought"
    $scope.loadOrders = ->
      return if $scope.data.orders.length >= $scope.data.count or $scope.data.loading
      MkmApiOrder.get {mode: $scope.mode, status, response:$scope.data}
]