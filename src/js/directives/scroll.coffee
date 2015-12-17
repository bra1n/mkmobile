# infinite scrolling
angular.module 'mkmobile.directives.scroll', []
.directive 'infiniteScroll', ->
  link: (scope, elm, attr) ->
# find the closest scrollable parent
    scrollElem = elm[0].parentNode
    scrollElem = scrollElem.parentNode while scrollElem.clientHeight is not scrollElem.scrollHeight
    # use the document if there aren't any scrollable parents
    scrollElem = document.documentElement unless scrollElem.scrollHeight > 0
    scrollHandler = ->
      if scrollElem.scrollTop + scrollElem.clientHeight - elm[0].offsetTop >= elm[0].scrollHeight - scrollElem.clientHeight
        scope.$apply attr.infiniteScroll
    angular.element(scrollElem).bind 'scroll', scrollHandler
    scope.$on '$destroy', -> angular.element(scrollElem).unbind 'scroll', scrollHandler