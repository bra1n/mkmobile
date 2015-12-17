# infinite scrolling
angular.module 'mkmobile.directives.scroll', []
.directive 'infiniteScroll', ['$window', ($window) ->
  scope:
    isContainer: "=?"
    infiniteScroll: "&"
  link: (scope, elm) ->
    scrollHandler = ->
      console.log "scroll", scrollElem.scrollTop + scrollElem.clientHeight - elm[0].offsetTop, elm[0].scrollHeight - scrollElem.clientHeight
      if scrollElem.scrollTop + scrollElem.clientHeight - elm[0].offsetTop >= elm[0].scrollHeight - scrollElem.clientHeight
        scope.infiniteScroll()

    if scope.isContainer
      scrollElem = elm[0]
      angular.element(scrollElem).bind 'scroll', scrollHandler
      scope.$on '$destroy', -> angular.element(scrollElem).unbind 'scroll', scrollHandler
    else
      scrollElem = document.getElementsByTagName('body')[0]
      angular.element($window).bind 'scroll', scrollHandler
      scope.$on '$destroy', -> angular.element($window).unbind 'scroll', scrollHandler
]