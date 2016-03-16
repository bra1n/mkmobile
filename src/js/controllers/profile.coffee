# /profile
angular.module 'mkmobile.controllers.profile', []
.controller 'ProfileCtrl', [
  '$scope', 'MkmApiAuth'
  ($scope, MkmApiAuth) ->
    $scope.data = MkmApiAuth.getAccount()
    $scope.updateVacation = -> MkmApiAuth.setVacation $scope.data.account.onVacation
]
