# home page
angular.module 'mkmobile.controllers.home', []
.controller 'HomeCtrl', [
  '$scope', 'MkmApiMessage', 'MkmApiAuth'
  ($scope, MkmApiMessage, MkmApiAuth) ->
    MkmApiAuth.getAccount (data) ->
      $scope.account = data.account
      $scope.messages = MkmApiMessage.count()
]
