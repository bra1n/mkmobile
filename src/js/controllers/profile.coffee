# /profile
angular.module 'mkmobile.controllers.profile', []
.controller 'ProfileCtrl', [
  'MkmApiAuth', '$translate'
  (MkmApiAuth, $translate) ->
    @account = {}
    @loading = yes
    @coupon = ""
    MkmApiAuth.getAccount ({@account, @loading}) => # store account in controller scope
    @updateVacation = => MkmApiAuth.setVacation @account.onVacation
    @submitCoupon = =>
      MkmApiAuth.redeemCoupon @coupon, ({@account, @messages}) =>
        if !@messages
          @coupon = ""
          $translate('profile.coupon_success').then (text) => alert text
    @
]
