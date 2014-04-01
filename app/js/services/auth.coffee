class ServiceAuth
  redirectAfterLogin = "/"

  constructor: ({@api, @auth, @location}) ->

  # get login status
  isLoggedIn: -> @auth.secret isnt ""

  # return login URL
  getLoginURL: -> 'https://www.mkmapi.eu/ws/authenticate/' + @auth.consumerKey

  # logout
  logout: ->
    @auth.secret = @auth.token = ""
    sessionStorage.removeItem "secret"
    sessionStorage.removeItem "token"
    @location.path '/login'

  # checks whether a user is logged in and redirects if necessary
  checkLogin: ->
    console.log "login check", @isLoggedIn()
    unless @isLoggedIn() and @location.path() isnt "/login"
      @redirectAfterLogin = @location.path()
      @location.path '/login'

  # log the user in and store tokens in the session
  getAccess: (requestToken) ->
    response = {}
    @auth.token = requestToken if requestToken?
    request =
      app_key: @auth.consumerKey
      request_token: @auth.token
    @api.access request, (data) =>
      if data.oauth_token and data.oauth_token_secret
        @auth.token = data.oauth_token
        @auth.secret = data.oauth_token_secret
        sessionStorage.setItem "auth", @auth.token
        sessionStorage.setItem "secret", @auth.secret
        response.success = yes
        @location.path @redirectAfterLogin
    , -> response.error = yes
    response = {}
