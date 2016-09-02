angular.module 'mkmobile.directives.user', []
.directive 'mkmUser', ->
  restrict: 'A'
  scope: user: "="
  templateUrl: '/partials/directives/user.html'
