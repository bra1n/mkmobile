mkmobileServices.factory 'MkmApiAuth', [
  'MkmApi', '$location', 'DataCache', 'tmhDynamicLocale', '$translate'
  (MkmApi, $location, DataCache, tmhDynamicLocale, $translate) ->
    redirectAfterLogin = "/"
    promises = {}

    # get login status
    isLoggedIn: -> MkmApi.auth.secret isnt ""

    # return login URL
    getLoginURL: -> MkmApi.url + MkmApi.auth.consumerKey

    # logout: remove session data, trash the cache, redirect to /login
    logout: ->
      MkmApi.auth.secret = MkmApi.auth.token = ""
      sessionStorage.removeItem "secret"
      sessionStorage.removeItem "token"
      sessionStorage.removeItem "search"
      DataCache.reset()
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
          @cache data.account
          response.success = yes
          $location.path redirectAfterLogin
      , -> response.error = yes
      response = {}

    # return the user object or load it if necessary
    getAccount: (cb) ->
      response = account: DataCache.account()
      unless response.account?
        response.loading = yes
        promises.account = (promises.account or MkmApi.api.account().$promise).then (data) =>
          response.account = @cache data.account
          response.loading = no
          cb?(response)
          data # pass data to the next callback
        , (error) =>
          # if request for account returns with a 403, it means we're logged out and don't know it yet
          @logout() if error.status is 403
      else
        cb?(response)
      response

    # update vacation status
    setVacation: (vacation) -> MkmApi.api.accountVacation {vacation}, (data) => @cache data.account

    # update interface language
    setLanguage: (languageId) -> MkmApi.api.accountLanguage {languageId}, (data) => @cache data.account

    # cache account data, update translations, returns account
    cache: (account) ->
      # locale changing
      for locale in @getLanguageCodes() when locale.value is account.idDisplayLanguage
        unless $translate.use() is locale.label
          tmhDynamicLocale.set locale.label.replace(/_/, '-')
          $translate.use locale.label
      DataCache.cartCount account.articlesInShoppingCart
      DataCache.messageCount account.unreadMessages
      DataCache.balance account.accountBalance
      return DataCache.account account

    # return list of available languages
    getLanguages: -> [
      { value: 1, label: "English" }
      { value: 2, label: "French" }
      { value: 3, label: "German" }
      { value: 4, label: "Spanish" }
      { value: 5, label: "Italian" }
    ]

    # return list of language ID to ISO code
    getLanguageCodes: -> [
      { value: 1, label: "en_GB" }
      { value: 2, label: "fr_FR" }
      { value: 3, label: "de_DE" }
      { value: 4, label: "es_ES" }
      { value: 5, label: "it_IT" }
    ]
]
