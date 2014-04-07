mkmobileServices.factory 'MkmApiAuth', [ 'MkmApi', '$location', (MkmApi, $location) ->
  redirectAfterLogin = "/"

  # get login status
  isLoggedIn: -> MkmApi.auth.secret isnt ""

  # return login URL
  getLoginURL: -> 'https://www.mkmapi.eu/ws/authenticate/' + MkmApi.auth.consumerKey

  # logout
  logout: ->
    MkmApi.auth.secret = MkmApi.auth.token = ""
    sessionStorage.removeItem "secret"
    sessionStorage.removeItem "token"
    $location.path '/login'

  # checks whether a user is logged in and redirects if necessary
  checkLogin: ->
    console.log "login check", @isLoggedIn()
    response = true
    unless @isLoggedIn() and $location.path() isnt "/login"
      redirectAfterLogin = $location.path()
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
        response.success = yes
        $location.path redirectAfterLogin
    , -> response.error = yes
    response = {}
]
