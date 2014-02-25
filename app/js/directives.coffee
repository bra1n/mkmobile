mkmobileDirectives = angular.module 'mkmobileDirectives', []

# infinite scrolling
mkmobileDirectives.directive 'infiniteScroll', () ->
  link: (scope, elm, attr) ->
    docElem = document.documentElement
    $(window).bind 'scroll', ->
      if docElem.scrollTop + docElem.clientHeight - elm[0].offsetTop >= elm[0].scrollHeight
        scope.$apply attr.infiniteScroll