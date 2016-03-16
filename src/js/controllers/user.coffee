# /profile
angular.module 'mkmobile.controllers.user', []
.controller 'UserCtrl', [
  '$scope', 'MkmApiAuth', 'MkmApiMarket', '$stateParams'
  ($scope, MkmApiAuth, MkmApiMarket, $stateParams) ->
    $scope.username = MkmApiAuth.getUsername()
    $scope.data = MkmApiMarket.getUser $stateParams.idUser
]
