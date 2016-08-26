# payment pages
angular.module 'mkmobile.controllers.payment', []
.controller 'PaymentCtrl', ($stateParams, MkmApiAuth, $location) ->
  @method = $stateParams.method
  # try closing the window straight away
  window.close() if @method in ['done', 'cancel']
  @data = MkmApiAuth.getAccount (data) =>
    $location.path("/").replace() if !data.account? or !data.account.moneyDetails.providerRechargeAmount
  @location = $location
  @languages = MkmApiAuth.getLanguageCodes()
  @redirect = -> $location.path("/").replace()
  @