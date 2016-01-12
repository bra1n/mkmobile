# login
angular.module 'mkmobile.controllers.contact', []
.controller 'ContactCtrl', [
  '$scope', 'MkmApi', '$translate'
  ($scope, MkmApi, $translate) ->
    $scope.submit = ->
      MkmApi.api.contact $scope.form, (response) ->
        $translate('contact.success').then (text) ->
          $scope.form = {}
          alert text
]