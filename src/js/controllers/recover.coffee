# /recover
angular.module 'mkmobile.controllers.recover', []
.controller 'RecoverCtrl', [
  'MkmApi', '$translate'
  (MkmApi, $translate) ->
    @submit = (type) ->
      MkmApi.api.accountLogindata {type}, {email: @email}, ->
        @email = ""
        $translate('recover.success_'+type).then (text) -> alert text
      , ->
        $translate('recover.error').then (text) -> alert text
    @
]