# footer logic, accepts cart and messages count variables
angular.module 'mkmobile.directives.footer', []
.directive 'mkmFooter', [
  'MkmApiAuth', 'MkmApiCart', 'MkmApiMessage'
  (MkmApiAuth, MkmApiCart, MkmApiMessage) ->
    scope:
      cart: "=?"
      messages: "=?"
    link: (scope) ->
      scope.loggedIn = MkmApiAuth.isLoggedIn()
      scope.cart or= MkmApiCart.count()
      scope.messages or= MkmApiMessage.count()
      unless (scope.cart? and scope.messages?) or !scope.loggedIn
        MkmApiAuth.getAccount ->
          scope.cart = MkmApiCart.count() unless scope.cart?
          scope.messages = MkmApiMessage.count() unless scope.messages?
    restrict: 'E'
    templateUrl: '/partials/directives/footer.html'
]
