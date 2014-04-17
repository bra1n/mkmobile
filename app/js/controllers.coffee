# search for / or /login
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', 'MkmApiAuth', 'MkmApiMarket', '$sce'
  ($scope, $routeParams, MkmApiAuth, MkmApiMarket, $sce) ->
    $scope.$watch 'query', (query) ->
      sessionStorage.setItem "search", query
      $scope.searchData = MkmApiMarket.search query
    # init scope vars
    $scope.query = sessionStorage.getItem("search") or ""
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
    $scope.data = MkmApiAuth.getAccount()
    $scope.updateVacation = -> MkmApiAuth.setVacation $scope.data.account.onVacation
    $scope.logout = -> MkmApiAuth.logout()
]

# home page
mkmobileControllers.controller 'HomeCtrl', [
  '$scope', ($scope) -> # do nothing!
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
    $scope.$watch 'query', (query) ->
      sessionStorage.setItem "search", query
      $scope.searchData = MkmApiMarket.search(query) unless $routeParams.orderId
    $scope.loadResults = ->
      unless $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
        MkmApiMarket.search($scope.query, $scope.searchData)
    $scope.query = sessionStorage.getItem("search") or ""
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
      order.articleCount-- # reduce total order count
      MkmApiCart.remove article.idArticle, ->
        if $routeParams.orderId? and !order.articleCount
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
    $scope.languages = [
      {id: 1, label: "EN"}
      {id: 2, label: "FR"}
      {id: 3, label: "DE"}
      {id: 4, label: "SP"}
      {id: 5, label: "IT"}
      {id: 6, label: "CH"}
      {id: 7, label: "JP"}
      {id: 8, label: "PT"}
      {id: 9, label: "RU"}
      {id: 10, label: "KO"}
      {id: 11, label: "TW"}
    ]
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
      sessionStorage.setItem $scope.mode + 'Tab', $scope.tab
      $scope.data = MkmApiOrder.get {mode: $scope.mode, status, orderId: $scope.orderId}
    $scope.tab = sessionStorage.getItem($scope.mode + 'Tab') or "bought"
    $scope.loadOrders = ->
      return if $scope.data.orders.length >= $scope.data.count or $scope.data.loading
      MkmApiOrder.get {mode: $scope.mode, status, response:$scope.data}
    # update order status
    $scope.update = (status) ->
      if status is 'requestCancellation' and !$scope.data.order.showReason
        $scope.data.order.showReason = yes
      else
        MkmApiOrder.update {orderId:$scope.orderId, status, reason:$scope.data.order.state.reason}, ->
          $scope.data = MkmApiOrder.get {orderId: $scope.orderId}
      false
]

# /messages
mkmobileControllers.controller 'MessageCtrl', [
  '$scope', '$routeParams', 'MkmApiMessage'
  ($scope, $routeParams, MkmApiMessage) ->
    $scope.data = MkmApiMessage.get $routeParams.userId
]