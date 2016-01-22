# /recover
angular.module 'mkmobile.controllers.register', []
.controller 'RegisterCtrl', [
  '$scope', 'MkmApi', '$translate'
  ($scope, MkmApi, $translate) ->
    $scope.steps = [1..5]
    $scope.step = 1
    $scope.go = (step) -> $scope.step = step
]