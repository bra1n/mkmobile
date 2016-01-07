# payment pages
angular.module 'mkmobile.controllers.payment', []
.controller 'PaymentCtrl', [
  '$scope', '$stateParams', 'MkmApiAuth', '$location'
  ($scope, $stateParams, MkmApiAuth, $location) ->
    $scope.method = $stateParams.method
    # try closing the window straight away
    window.close() if $scope.method in ['done', 'cancel']
    $scope.data = MkmApiAuth.getAccount (data) ->
      $location.path("/").replace() if !data.account? or !data.account.paypalRecharge and $scope.method is "paypal"
      $location.path("/").replace() if !data.account? or !data.account.bankRecharge and $scope.method is "bank"
    $scope.location = $location
    $scope.languages = MkmApiAuth.getLanguageCodes()
    $scope.redirect = -> $location.path("/").replace()
]
