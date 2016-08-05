# login
angular.module 'mkmobile.controllers.login', []
.controller 'LoginCtrl', ($rootScope, MkmApiAuth, $sce, $translate) ->
  @loggedIn = MkmApiAuth.isLoggedIn()
  @iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()+"/"+$translate.use().substr(0,2)
  @gameId = window.gameId or 1

  # listen to language changes and reload iframe
  $rootScope.$on '$translateChangeSuccess', =>
    unless @login
      @iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()+"/"+$translate.use().substr(0,2)

  # handle login callback
  window.handleCallback = (token) =>
    @login = MkmApiAuth.getAccess token
    delete window.handleCallback

  # log the user out
  @logout = =>
    MkmApiAuth.logout()
    @loggedIn = no
  @