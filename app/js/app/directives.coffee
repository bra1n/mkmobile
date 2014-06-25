mkmobileDirectives = angular.module 'mkmobileDirectives', []

# infinite scrolling
mkmobileDirectives.directive 'infiniteScroll', ->
  link: (scope, elm, attr) ->
    docElem = document.documentElement
    scrollHandler = ->
      if (docElem.scrollTop or window.pageYOffset) + docElem.clientHeight - elm[0].offsetTop >= elm[0].scrollHeight - window.innerHeight
        scope.$apply attr.infiniteScroll
    $(window).bind 'scroll', scrollHandler
    scope.$on '$destroy', -> $(window).unbind 'scroll', scrollHandler

# footer logic, accepts cart and messages count variables
mkmobileDirectives.directive 'mkmFooter', [
  'MkmApiAuth', 'MkmApiCart', 'MkmApiMessage'
  (MkmApiAuth, MkmApiCart, MkmApiMessages) ->
    scope:
      cart: "=?"
      messages: "=?"
    link: (scope) ->
      scope.loggedIn = MkmApiAuth.isLoggedIn()
      scope.cart or= MkmApiCart.count()
      scope.messages or= MkmApiMessages.count()
      unless (scope.cart? and scope.messages?) or !scope.loggedIn
        MkmApiAuth.getAccount ->
          scope.cart = MkmApiCart.count() unless scope.cart?
          scope.messages = MkmApiMessages.count() unless scope.messages?
    restrict: 'E'
    replace: yes
    templateUrl: '/partials/directives/footer.html'
]

mkmobileDirectives.directive 'mkmOrder', [ 'MkmApiCart', (MkmApiCart) ->
  scope:
    order: "="
    removeArticle: "="
    shippingMethod: "="
  link: (scope) -> scope.countries = MkmApiCart.getCountries()
  restrict: 'E'
  templateUrl: '/partials/directives/order.html'
]

# dumb templates
mkmobileDirectives.directive 'mkmSearch', ->
  restrict: 'E'
  transclude: yes
  templateUrl: '/partials/directives/search.html'

mkmobileDirectives.directive 'mkmUser', ->
  restrict: 'A'
  scope: user: "="
  templateUrl: '/partials/directives/user.html'

mkmobileDirectives.directive 'mkmProduct', ->
  restrict: 'E'
  scope: productData: "="
  templateUrl: '/partials/directives/product.html'