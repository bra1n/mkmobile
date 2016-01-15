# /recover
angular.module 'mkmobile.controllers.register', []
.controller 'RegisterCtrl', [
  '$scope', 'MkmApi', '$translate'
  ($scope, MkmApi, $translate) ->
    console.log "register"
]