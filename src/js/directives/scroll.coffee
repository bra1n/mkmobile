# infinite scrolling
angular.module 'mkmobile.directives.scroll', []
.directive 'infiniteScroll', ['$window', ($window) ->
  scope:
    isContainer: "=?"
    infiniteScroll: "&"
  link: (scope, elm) ->
    scrollHandler = ->
      if scrollElem.scrollTop + scrollElem.clientHeight - elm[0].offsetTop >= elm[0].scrollHeight - scrollElem.clientHeight
        scope.infiniteScroll()
    if scope.isContainer
      # infinite scroll inside a container with overflow
      scrollElem = elm[0]
      angular.element(scrollElem).bind 'scroll', scrollHandler
      scope.$on '$destroy', -> angular.element(scrollElem).unbind 'scroll', scrollHandler
    else
      # infinite scroll inside the document body
      scrollElem = document.getElementsByTagName('body')[0]
      angular.element($window).bind 'scroll', scrollHandler
      scope.$on '$destroy', -> angular.element($window).unbind 'scroll', scrollHandler
]