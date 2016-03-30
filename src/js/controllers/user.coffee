# /profile
angular.module 'mkmobile.controllers.user', []
.controller 'UserCtrl', [
  'MkmApiAuth', 'MkmApiMarket', '$stateParams'
  (MkmApiAuth, MkmApiMarket, $stateParams) ->
    @username = MkmApiAuth.getUsername()
    @data = MkmApiMarket.getUser $stateParams.idUser
    @
]
