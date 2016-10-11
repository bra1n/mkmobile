angular.module 'mkmobile.services.auth', []
.factory 'MkmApiAuth', (MkmApi, $state, DataCache, tmhDynamicLocale, $translate, $rootScope) ->
  redirectAfterLogin = name: "home", params: {}
  promises = {}

  # get login status
  isLoggedIn: -> !!MkmApi.auth.secret

  # return login URL
  getLoginURL: -> MkmApi.url + MkmApi.auth.consumerKey

  # return username, if any
  getUsername: -> MkmApi.auth.username

  # logout: remove session data, trash the cache, redirect to /login
  logout: ->
    MkmApi.api.accountLogout()
    MkmApi.auth.secret = MkmApi.auth.token = MkmApi.auth.username = ""
    try
      sessionStorage.removeItem "auth"
      sessionStorage.removeItem "search"
      sessionStorage.removeItem "filter"
    DataCache.reset()
    $rootScope.$broadcast '$authChange', {}
    $state.go "login"

  # checks whether a user is logged in and redirects if necessary
  checkLogin: (next) ->
    response = @isLoggedIn()
    unless response or $state.is "login"
      unless $state.current.name in ["register", "recover"]
        redirectAfterLogin = $state.current
        redirectAfterLogin.params or= $state.params # for some reason, those are not in state.current?
      $state.go "login"
      response = false
    if DataCache.account()?.isActivated is false and (!next or next.name isnt "activation.account")
      $state.go "activation.account"
      response = false
    response

  # log the user in and store auth in the session
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
        MkmApi.auth.username = data.account.username
        # store auth data in the session
        try sessionStorage.setItem "auth", JSON.stringify {
          token: MkmApi.auth.token
          secret: MkmApi.auth.secret
          username: MkmApi.auth.username
        }
        @cache data.account
        response.success = yes
        $rootScope.$broadcast '$authChange', data.account
        if data.account.isActivated
          $state.go redirectAfterLogin.name, redirectAfterLogin.params
        else
          $state.go "activation.account"
    , -> response.error = yes
    response

  # return the user object or load it if necessary
  getAccount: (cb) ->
    response = account: DataCache.account()
    if !response.account? && @isLoggedIn()
      response.loading = yes
      unless promises.account
        promises.account = MkmApi.api.account().$promise.then (data) =>
          response.account = @cache data.account
          response.loading = no
        , (error) =>
          # if request for account returns with a 403, it means we're logged out and don't know it yet
          @logout() if error.status in [403, 401]
      promises.account.then ->
        response.account = DataCache.account()
        response.loading = no
        cb?(response)
    else
      cb?(response)
    response

  # update vacation status
  setVacation: (vacation) -> MkmApi.api.accountVacation {vacation}, (data) => @cache data.account

  # redeem coupon
  redeemCoupon: (couponCode, cb) ->
    MkmApi.api.accountCoupon {couponCode}, (data) =>
      @cache data.account
      cb? data
    , cb

  # update interface language and save it in profile
  setLanguage: (languageId) ->
    for locale in @getLanguageCodes() when locale.value is languageId
      unless $translate.use() is locale.label
        tmhDynamicLocale.set locale.label.replace(/_/, '-').toLowerCase()
        $translate.use locale.label
    if @isLoggedIn()
      MkmApi.api.accountLanguage {languageId}, (data) => @cache data.account

  # get current language id
  getLanguage: ->
    id = 1
    id = language.value for language in @getLanguageCodes() when language.label is $translate.use()
    id

  # cache account data, update translations, return account
  cache: (account) ->
    # locale changing
    for locale in @getLanguageCodes() when locale.value is account.idDisplayLanguage
      unless $translate.use() is locale.label
        tmhDynamicLocale.set locale.label.replace(/_/, '-').toLowerCase()
        $translate.use locale.label
    DataCache.cartCount account.articlesInShoppingCart
    DataCache.messageCount account.unreadMessages
    DataCache.balance account.accountBalance
    $rootScope.$broadcast '$cartChange', account.articlesInShoppingCart
    return DataCache.account account

  # return list of available languages
  getLanguages: -> [1..5]

  # return list of language ID to ISO code
  getLanguageCodes: -> [
    { value: 1, label: "en_GB" }
    { value: 2, label: "fr_FR" }
    { value: 3, label: "de_DE" }
    { value: 4, label: "es_ES" }
    { value: 5, label: "it_IT" }
  ]

  # activate account / resend activation
  activateAccount: (activationCode, cb) ->
    if activationCode
      MkmApi.api.accountActivation {activationCode}, (data) =>
        cb? @cache data.account
      , cb
    else
      MkmApi.api.accountActivationResend {}, cb

  # activate seller / request activation transfers
  activateSeller: (request, cb) ->
    if request.iban
      MkmApi.api.sellerActivationRequest request, (data) =>
        cb? @cache data.account
      , cb
    else
      MkmApi.api.sellerActivation request, (data) =>
        cb? @cache data.account
      , cb
