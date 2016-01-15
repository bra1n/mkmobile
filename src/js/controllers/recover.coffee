# /recover
angular.module 'mkmobile.controllers.recover', []
.controller 'RecoverCtrl', [
  '$scope', 'MkmApi', '$translate'
  ($scope, MkmApi, $translate) ->
    $scope.submit = (type) ->
      MkmApi.api.accountLogindata {type}, {email: $scope.email}, ->
        $scope.email = ""
        $translate('recover.success_'+type).then (text) -> alert text
      , ->
        $translate('recover.error').then (text) -> alert text
]