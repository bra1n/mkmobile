# login
angular.module 'mkmobile.controllers.login', []
.controller 'LoginCtrl', [
  '$scope', 'MkmApiAuth', '$sce', '$translate'
  ($scope, MkmApiAuth, $sce, $translate) ->
    $scope.iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()+"/"+$scope.language
    # listen to language changes and reload iframe
    $scope.$root.$on '$translateChangeSuccess', ->
      $scope.iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()+"/"+$translate.use().substr(0,2)
    window.handleCallback = (token) ->
      $scope.login = MkmApiAuth.getAccess token
      delete window.handleCallback

    $scope.loggedIn = MkmApiAuth.isLoggedIn()
    $scope.logout = ->
      MkmApiAuth.logout()
      $scope.loggedIn = no
]