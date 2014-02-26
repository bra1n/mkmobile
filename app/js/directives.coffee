mkmobileDirectives = angular.module 'mkmobileDirectives', []

# infinite scrolling
mkmobileDirectives.directive 'infiniteScroll', ->
  link: (scope, elm, attr) ->
    docElem = document.documentElement
    scrollHandler = ->
      if docElem.scrollTop + docElem.clientHeight - elm[0].offsetTop >= elm[0].scrollHeight
        scope.$apply attr.infiniteScroll
    $(window).bind 'scroll', scrollHandler
    scope.$on '$destroy', -> $(window).unbind 'scroll', scrollHandler