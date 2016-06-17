# /seller
angular.module 'mkmobile.controllers.user', []
.controller 'UserCtrl', [
  '$stateParams', 'MkmApiMarket', 'MkmApiAuth', 'MkmApiCart'
  ($stateParams, MkmApiMarket, MkmApiAuth, MkmApiCart) ->
    @seller = idUser: $stateParams.idUser
    @
]
