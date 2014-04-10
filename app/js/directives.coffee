mkmobileDirectives = angular.module 'mkmobileDirectives', []

# infinite scrolling
mkmobileDirectives.directive 'infiniteScroll', ->
  link: (scope, elm, attr) ->
    docElem = document.documentElement
    scrollHandler = ->
      if (docElem.scrollTop or window.pageYOffset) + docElem.clientHeight - elm[0].offsetTop >= elm[0].scrollHeight
        scope.$apply attr.infiniteScroll
    $(window).bind 'scroll', scrollHandler
    scope.$on '$destroy', -> $(window).unbind 'scroll', scrollHandler

mkmobileDirectives.directive 'mkmFooter', [ 'MkmApiAuth', 'MkmApiCart', (MkmApiAuth, MkmApiCart) ->
  scope: cart: "=?"
  link: (scope) ->
    scope.loggedIn = MkmApiAuth.isLoggedIn()
    scope.cart = scope.cart or MkmApiCart.count()
  restrict: 'E'
  replace: yes
  templateUrl: '/partials/directives/footer.html'
]

mkmobileDirectives.directive 'mkmSearch', ->
  restrict: 'E'
  transclude: yes
  templateUrl: '/partials/directives/search.html'

mkmobileDirectives.directive 'mkmOrder', ->
  restrict: 'E'
  scope:
    order: "="
    removeArticle: "="
  templateUrl: '/partials/directives/order.html'

mkmobileDirectives.directive 'mkmUser', ->
  restrict: 'A'
  scope: user: "="
  templateUrl: '/partials/directives/user.html'

mkmobileDirectives.directive 'mkmProduct', ->
  restrict: 'E'
  scope: productData: "="
  templateUrl: '/partials/directives/product.html'