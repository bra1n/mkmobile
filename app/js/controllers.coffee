# search
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', 'MkmApiAuth', 'MkmApiMarket', '$sce'
  ($scope, $routeParams, MkmApiAuth, MkmApiMarket, $sce) ->
    $scope.$watch 'query', (query) ->
      sessionStorage.setItem "search", query
      $scope.searchData = MkmApiMarket.search query
    # init scope vars
    $scope.query = sessionStorage.getItem("search") or ""
    $scope.sort = "name[0]['productName']"

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
    $scope.languages = MkmApiAuth.getLanguages()
    $scope.updateVacation = -> MkmApiAuth.setVacation $scope.data.account.onVacation
    $scope.updateLanguage = -> MkmApiAuth.setLanguage $scope.data.account.language
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
    $scope.sort = "name[0]['productName']"

    # load cart data
    $scope.data = MkmApiCart.get $routeParams.orderId, ->
      $scope.count = MkmApiCart.count()
      $scope.sum = MkmApiCart.sum()
      $location.path "/cart" if $scope.count is 0 and ($routeParams.orderId? or $routeParams.method?)

    # remove a single article
    $scope.removeArticle = (article, order) ->
      article.count-- # card count for this article
      $scope.count-- # total cart count
      order.articleCount-- # reduce total order count
      order.totalValue -= article.price # reduce total order count
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
      MkmApiCart.remove articles, ->
        $scope.count = MkmApiCart.count()
        $scope.sum = MkmApiCart.sum()
        $scope.data = MkmApiCart.get $routeParams.orderId # should be updated now, no need for callback

    # change shipping address
    $scope.countries = MkmApiCart.getCountries()
    $scope.shippingAddress = (address) -> MkmApiCart.shippingAddress address, -> $location.path '/cart'

    # change shipping method
    $scope.shippingMethod = (order) -> MkmApiCart.shippingMethod order

    # checkout
    $scope.method = $routeParams.method
    $scope.checkout = ->
      MkmApiCart.checkout ->
        sessionStorage.setItem 'buysTab', (if $scope.method is 'instabuy' then 'paid' else 'bought')
        $location.path '/buys'
]

# /stock
mkmobileControllers.controller 'StockCtrl', [
  '$scope', '$location', '$routeParams', 'MkmApiStock'
  ($scope, $location, $routeParams, MkmApiStock) ->
    # selecting an article in stock
    $scope.selected = []
    $scope.select = (id) ->
      if id in $scope.selected
        $scope.selected.splice $scope.selected.indexOf(id), 1
      else
        $scope.selected.push id

    # search logic / loading article data
    $scope.$watch 'query', (query) ->
      sessionStorage.setItem "searchStock", query
      if !query or $routeParams.articleId
        $scope.data = MkmApiStock.get $routeParams.articleId
      else
        $scope.data = MkmApiStock.search query
    $scope.loadArticles = ->
      unless $scope.data.articles.length >= $scope.data.count or $scope.data.loading
        if !queryg or $routeParams.articleId
          MkmApiStock.get $routeParams.articleId, $scope.data
        else
          MkmApiStock.search $scope.query, $scope.data
    $scope.query = sessionStorage.getItem("searchStock") or ""

    # increase article count
    $scope.increase = (articles) -> MkmApiStock.increase(article) for article in articles
    # decrease article count
    $scope.decrease = (articles) -> MkmApiStock.decrease(article) for article in articles

    # edit article stuff
    $scope.languages = MkmApiStock.getLanguages()
    $scope.conditions = MkmApiStock.getGradings()
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
          $location.path('/'+$scope.mode+'/'+$scope.orderId+'/evaluate') if status is "confirmReception"
      false
    # evaluate order
    $scope.evaluations = MkmApiOrder.getEvaluations()
    $scope.complaints = MkmApiOrder.getComplaints()
    $scope.evaluation = MkmApiOrder.getEvaluation()
    $scope.evaluate = -> MkmApiOrder.evaluate $scope.orderId, $scope.evaluation, -> $location.path "/"+$scope.mode+"/"+$scope.orderId
]

# /messages
mkmobileControllers.controller 'MessageCtrl', [
  '$scope', '$routeParams', 'MkmApiMessage'
  ($scope, $routeParams, MkmApiMessage) ->
    $scope.data = MkmApiMessage.get $routeParams.userId
    $scope.send = -> MkmApiMessage.send $routeParams.userId, $scope.message, (message) ->
      $scope.data.messages.unshift message
      $scope.data.count++
]