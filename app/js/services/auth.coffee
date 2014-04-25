mkmobileServices.factory 'MkmApiAuth', [ 'MkmApi', '$location', 'DataCache', (MkmApi, $location, DataCache) ->
  redirectAfterLogin = "/"
  promises = {}

  # get login status
  isLoggedIn: -> MkmApi.auth.secret isnt ""

  # return login URL
  getLoginURL: -> MkmApi.url + MkmApi.auth.consumerKey

  # logout
  logout: ->
    MkmApi.auth.secret = MkmApi.auth.token = ""
    sessionStorage.removeItem "secret"
    sessionStorage.removeItem "token"
    sessionStorage.removeItem "search"
    $location.path '/login'

  # checks whether a user is logged in and redirects if necessary
  checkLogin: ->
    console.log "login check", @isLoggedIn()
    response = true
    unless @isLoggedIn() and $location.path() isnt "/login"
      redirectAfterLogin = $location.path()
      sessionStorage.removeItem "search"
      $location.path '/login'
      response = false
    response

  # log the user in and store tokens in the session
  getAccess: (requestToken) ->
    response = {}
    MkmApi.auth.token = requestToken if requestToken?
    request =
      app_key: MkmApi.auth.consumerKey
      request_token: MkmApi.auth.token
    MkmApi.api.access request, (data) =>
      if data.oauth_token and data.oauth_token_secret
        MkmApi.auth.token = data.oauth_token
        MkmApi.auth.secret = data.oauth_token_secret
        sessionStorage.setItem "token", MkmApi.auth.token
        sessionStorage.setItem "secret", MkmApi.auth.secret
        DataCache.account data.user
        DataCache.cartCount data.articlesInShoppingCart
        DataCache.messageCount data.unreadMessages
        response.success = yes
        $location.path redirectAfterLogin
    , -> response.error = yes
    response = {}

  # return the user object or load it if necessary
  getAccount: (cb) ->
    response = account: DataCache.account()
    unless response.account?
      promises.account = (promises.account or MkmApi.api.account().$promise).then (data) ->
        response.account = DataCache.account data.account
        DataCache.cartCount data.articlesInShoppingCart
        DataCache.messageCount data.unreadMessages
        cb?()
        data # pass data to the next callback
      , (error) =>
        # if request for account returns with a 403, it means we're logged out and don't know it yet
        @logout() if error.status is 403
    response

  # update vacation status
  setVacation: (vacation) ->
    MkmApi.api.accountVacation {param2: vacation}, (data) ->
      account = DataCache.account()
      if account?
        account.onVacation = data.onVacation
        DataCache.account account
]
