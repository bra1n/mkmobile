# login
angular.module 'mkmobile.controllers.contact', []
.controller 'ContactCtrl', ($scope, MkmApi, $translate) ->
  $scope.submit = ->
    MkmApi.api.contact $scope.form, ->
      $translate('contact.success').then (text) ->
        $scope.form = {}
        alert text