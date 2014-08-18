# search
mkmobileControllers.controller 'SearchCtrl', [
  '$scope', '$routeParams', 'MkmApiAuth', 'MkmApiMarket', '$sce'
  ($scope, $routeParams, MkmApiAuth, MkmApiMarket, $sce) ->
    $scope.$watch 'query', (query) ->
      sessionStorage.setItem "search", query
      $scope.searchData = MkmApiMarket.search query
    # init scope vars
    $scope.query = sessionStorage.getItem("search") or ""
    $scope.sort = "name[1]['productName']"

    # infinite scrolling
    $scope.loadResults = ->
      # don't load more if we already show all of them
      return if $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
      MkmApiMarket.search $scope.query, $scope.searchData

    # handle login
    $scope.loggedIn = MkmApiAuth.isLoggedIn()
    $scope.handleLogin = ->
      $scope.iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()+"/"+$scope.language
      window.handleCallback = (token) ->
        $scope.login = MkmApiAuth.getAccess token
        delete window.handleCallback
    $scope.logout = ->
      MkmApiAuth.logout()
      $scope.loggedIn = no

    # blur the search input
    $scope.blur = ($event) -> elem.blur() for elem in $event.target
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
        # reduce the amount before receiving the server response to prevent adding too many to the cart
        article.count--
        MkmApiCart.add article.idArticle, ->
          $scope.cart = MkmApiCart.count()
]

# /settings
mkmobileControllers.controller 'SettingsCtrl', [
  '$scope', 'MkmApiAuth'
  ($scope, MkmApiAuth) ->
    $scope.data = MkmApiAuth.getAccount()
    $scope.languages = MkmApiAuth.getLanguages()
    $scope.updateVacation = -> MkmApiAuth.setVacation $scope.data.account.onVacation
    $scope.updateLanguage = -> MkmApiAuth.setLanguage $scope.data.account.idDisplayLanguage
    $scope.logout = -> MkmApiAuth.logout()
]

# home page
mkmobileControllers.controller 'HomeCtrl', [
  '$scope', ($scope) -> # nothing to do!
]

# payment pages
mkmobileControllers.controller 'PaymentCtrl', [
  '$scope', '$routeParams', 'MkmApiAuth', '$location'
  ($scope, $routeParams, MkmApiAuth, $location) ->
    $scope.method = $routeParams.method
    # try closing the window straight away
    window.close() if $scope.method in ['done', 'cancel']
    $scope.data = MkmApiAuth.getAccount (data) ->
      $location.path("/").replace() if !data.account.paypalRecharge and $scope.method is "paypal"
      $location.path("/").replace() if !data.account.bankRecharge and $scope.method is "bank"
    $scope.location = $location
    $scope.languages = MkmApiAuth.getLanguageCodes()
    $scope.redirect = -> $location.path("/").replace()
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
  '$scope', '$location', '$routeParams', 'MkmApiCart', 'MkmApiMarket', '$translate'
  ($scope, $location, $routeParams, MkmApiCart, MkmApiMarket, $translate) ->
    # load cart data
    $scope.data = MkmApiCart.get $routeParams.orderId, ->
      $scope.count = MkmApiCart.count()
      $scope.sum = MkmApiCart.sum()
      if $scope.count is 0 and ($routeParams.orderId? or $routeParams.method?)
        $location.path("/cart").replace()

    # remove a single article
    $scope.removeArticle = (article, order) ->
      article.count-- # card count for this article
      $scope.count-- # total cart count
      order.articleCount-- # reduce total order count
      order.totalValue -= article.price # reduce total order count
      MkmApiCart.remove article.idArticle, ->
        if $routeParams.orderId? and !order.articleCount
          $location.path("/cart").replace()
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

    # empty the shopping cart
    $scope.emptyCart = ->
      $scope.data.cart = []
      $scope.count =  $scope.sum = 0
      MkmApiCart.empty()

    # change shipping address
    $scope.countries = MkmApiCart.getCountries()
    $scope.shippingAddress = (address) -> MkmApiCart.shippingAddress address, -> $location.path '/cart'

    # change shipping method
    $scope.shippingMethod = (order) -> MkmApiCart.shippingMethod order

    # checkout
    $scope.method = $routeParams.method
    $scope.checkout = -> $translate('checkout.are_you_sure').then (text) ->
      return unless confirm text
      $scope.clicked = yes
      MkmApiCart.checkout ->
        sessionStorage.setItem 'buysTab', (if $scope.method is 'instabuy' then 'paid' else 'bought')
        $location.path switch $scope.method
          when 'paypal' then '/payment/paypal'
          when 'bank' then '/payment/bank'
          else '/buys'
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
      $scope.selected = []
      sessionStorage.setItem "searchStock", query
      if !query or $routeParams.articleId
        $scope.data = MkmApiStock.get $routeParams.articleId
      else
        $scope.data = MkmApiStock.search query
    $scope.loadArticles = ->
      unless $scope.data.articles.length >= $scope.data.count or $scope.data.loading
        if !$scope.query or $routeParams.articleId
          MkmApiStock.get $routeParams.articleId, $scope.data
        else
          MkmApiStock.search $scope.query, $scope.data
    $scope.query = sessionStorage.getItem("searchStock") or ""

    # change article counts
    $scope.increase = (articles) -> MkmApiStock.updateBatch articles, 1
    $scope.decrease = (articles) -> MkmApiStock.updateBatch articles, -1

    # edit article stuff
    $scope.languages = MkmApiStock.getLanguages()
    $scope.conditions = MkmApiStock.getConditions()
    $scope.save = -> MkmApiStock.update $scope.data.article, -> $location.path "/stock"

    # blur search input
    $scope.blur = ($event) -> elem.blur() for elem in $event.target
]

# /buys /sells
mkmobileControllers.controller 'OrderCtrl', [
  '$scope', '$location', '$routeParams', 'MkmApiOrder', '$window'
  ($scope, $location, $routeParams, MkmApiOrder, $window) ->
    $scope.mode = $location.path().substr(1).replace /^(.*?)\/.*?$/, '$1'
    $scope.orderId = $routeParams.orderId
    $window.scrollTo(0,0) if $scope.orderId?
    $scope.$watch "tab", (status) ->
      sessionStorage.setItem $scope.mode + 'Tab', $scope.tab
      $scope.data = MkmApiOrder.get {mode: $scope.mode, status, orderId: $scope.orderId}
    $scope.tab = sessionStorage.getItem($scope.mode + 'Tab') or "bought"
    $scope.loadOrders = ->
      return if $scope.data.orders.length >= $scope.data.count or $scope.data.loading
      MkmApiOrder.get {mode: $scope.mode, status:$scope.tab, response:$scope.data}
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
    $scope.hideOverlay = 0
    $scope.evaluate = -> MkmApiOrder.evaluate $scope.orderId, $scope.evaluation, -> $location.path "/"+$scope.mode+"/"+$scope.orderId
]

# /messages
mkmobileControllers.controller 'MessageCtrl', [
  '$scope', '$routeParams', 'MkmApiMessage', '$translate'
  ($scope, $routeParams, MkmApiMessage, $translate) ->
    $scope.unreadCount = MkmApiMessage.count()
    $scope.data = MkmApiMessage.get $routeParams.userId, -> $scope.unreadCount = MkmApiMessage.count()
    # search for user
    $scope.$watch "search", (search) -> MkmApiMessage.findUser search, (users) ->
      filtered = []
      $scope.users = []
      filtered.push thread.partner.idUser for thread in $scope.data.messages
      $scope.users.push user for user in users when user.idUser not in filtered
    # send a new message
    $scope.send = ->
      MkmApiMessage.send $routeParams.userId, $scope.message, $scope.data
      $scope.message = ""
      false
    # delete a message
    $scope.delete = (index, threadId, messageId) -> $translate('messages.are_you_sure').then (text) ->
      return unless confirm text
      $scope.data.count--
      $scope.data.messages.splice index, 1
      MkmApiMessage.delete threadId, messageId
      
    # blur the search input
    $scope.blur = ($event) -> elem.blur() for elem in $event.target
]