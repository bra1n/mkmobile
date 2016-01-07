# login
angular.module 'mkmobile.controllers.contact', []
.controller 'ContactCtrl', [
  '$scope', 'MkmApiAuth', '$sce', '$translate'
  ($scope, MkmApiAuth, $sce, $translate) ->
    console.log "blah"
]