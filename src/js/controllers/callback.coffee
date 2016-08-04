# /callback
angular.module 'mkmobile.controllers.callback', []
.controller 'CallbackCtrl', ($scope, $location) ->
  search = $location.search()
  if search['request_token']?
    window.parent.handleCallback? search['request_token']