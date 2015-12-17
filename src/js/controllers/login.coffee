# login
angular.module 'mkmobile.controllers.login', []
.controller 'LoginCtrl', [
  '$scope', 'MkmApiAuth', '$sce'
  ($scope, MkmApiAuth, $sce) ->
    $scope.iframeSrc = $sce.trustAsResourceUrl MkmApiAuth.getLoginURL()+"/"+$scope.language
    window.handleCallback = (token) ->
      $scope.login = MkmApiAuth.getAccess token
      delete window.handleCallback

    $scope.loggedIn = MkmApiAuth.isLoggedIn()
    $scope.logout = ->
      MkmApiAuth.logout()
      $scope.loggedIn = no
]