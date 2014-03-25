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

mkmobileDirectives.directive 'footerMenu', [
  'MkmApi', (MkmApi) ->
    scope: cart: "=?"
    link: (scope) ->
      scope.loggedIn = MkmApi.isLoggedIn()
      scope.cart = scope.cart or MkmApi.getCartCount()
    restrict: 'E'
    replace: yes
    templateUrl: '/partials/footer.html'
]