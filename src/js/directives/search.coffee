angular.module 'mkmobile.directives.search', []
.directive 'mkmSearch', ->
  restrict: 'E'
  transclude: yes
  templateUrl: '/partials/directives/search.html'