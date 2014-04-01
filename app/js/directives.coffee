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

mkmobileDirectives.directive 'mkmFooter', [
  'MkmApi', (MkmApi) ->
    scope: cart: "=?"
    link: (scope) ->
      scope.loggedIn = MkmApi.auth.isLoggedIn()
      scope.cart = scope.cart or MkmApi.cart.count()
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

mkmobileDirectives.directive 'mkmSeller', ->
  restrict: 'A'
  scope: seller: "="
  templateUrl: '/partials/directives/seller.html'

mkmobileDirectives.directive 'mkmProduct', ->
  restrict: 'E'
  scope: productData: "="
  templateUrl: '/partials/directives/product.html'