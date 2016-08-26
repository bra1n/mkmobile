# /profile
angular.module 'mkmobile.controllers.profile', []
.controller 'ProfileCtrl', (MkmApiAuth, MkmApiMarket, $translate, $stateParams, $state) ->
  if $stateParams.idUser
    @username = MkmApiAuth.getUsername()
    @data = MkmApiMarket.getUser $stateParams.idUser
  else
    @account = {}
    @loading = yes
    @couponCode = ""
    MkmApiAuth.getAccount ({@account, @loading}) => # store account in controller scope
    @updateVacation = => MkmApiAuth.setVacation @account.onVacation
    @submitCoupon = =>
      @coupon = []
      MkmApiAuth.redeemCoupon @couponCode, ({@account, @coupon}) =>
        if @coupon && @coupon[0].successful
          @couponCode = ""
          $translate('profile.coupon_success').then (text) => alert text
          $state.go 'profile.account'
  @
