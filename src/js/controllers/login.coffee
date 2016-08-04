# login
angular.module 'mkmobile.controllers.login', []
.controller 'LoginCtrl', ($scope, MkmApiAuth, $sce, $translate) ->
  $scope.loggedIn = MkmApiAuth.isLoggedIn()
  $scope.iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()+"/"+$translate.use().substr(0,2)

  # listen to language changes and reload iframe
  $scope.$root.$on '$translateChangeSuccess', ->
    unless $scope.login
      $scope.iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()+"/"+$translate.use().substr(0,2)

  # handle login callback
  window.handleCallback = (token) ->
    $scope.login = MkmApiAuth.getAccess token
    delete window.handleCallback

  # log the user out
  $scope.logout = ->
    MkmApiAuth.logout()
    $scope.loggedIn = no