# /activation
angular.module "mkmobile.controllers.activation", []
.controller "ActivationCtrl", [
  "MkmApiAuth", "$translate", "$state"
  (MkmApiAuth, $translate, $state) ->
    # account activation
    @account = =>
      @error = no
      MkmApiAuth.activateAccount @code, (account) =>
        if account.isActivated
          $translate("activation.account.success").then (text) -> alert text
          $state.go "home"
        else
          @error = yes

    @resend = =>
      @resendRequested = yes
      MkmApiAuth.activateAccount "", =>
        $translate("activation.account.success_resend").then (text) -> alert text

    # seller activation
    @form = {}
    @steps = []
    @step = 0
    @loading = yes
    MkmApiAuth.getAccount ({@account, @loading}) => # store account in controller scope

    # go to seller account activation form step
    @go = (to) =>
      return for step, index in @steps when step.$invalid and index < to
      @step = to

    # activate seller account / request verification transfers
    @seller = =>
      MkmApiAuth.activateSeller @form, ({account, data}) =>
        if account
          @account = account
          # activation successful
          message = if @account.maySell then "success2" else "success"
          $translate("activation.seller." + message).then (text) =>
            alert text
            $state.go 'home'
        else
          # activation error (error in data)
          $translate("activation.seller.error").then (text) =>
            alert text
    @
]