# /activation
angular.module 'mkmobile.controllers.activation', []
.controller 'ActivationCtrl', [
  'MkmApiAuth', '$translate', '$state'
  (MkmApiAuth, $translate, $state) ->
    @submit = =>
      @error = no
      MkmApiAuth.activateAccount @code, (account) =>
        if account.isActivated
          $translate("activation.success").then (text) -> alert text
          $state.go 'home'
        else
          @error = yes

    @resend = =>
      @resendRequested = yes
      MkmApiAuth.activateAccount "", =>
        $translate("activation.success_resend").then (text) -> alert text
    @
]