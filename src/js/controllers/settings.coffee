# /settings
angular.module 'mkmobile.controllers.settings', []
.controller 'SettingsCtrl', [
  '$scope', 'MkmApiAuth'
  ($scope, MkmApiAuth) ->
    $scope.data = MkmApiAuth.getAccount()
    $scope.languages = MkmApiAuth.getLanguages()
    $scope.updateVacation = -> MkmApiAuth.setVacation $scope.data.account.onVacation
    $scope.updateLanguage = -> MkmApiAuth.setLanguage $scope.data.account.idDisplayLanguage
    $scope.logout = -> MkmApiAuth.logout()
]
