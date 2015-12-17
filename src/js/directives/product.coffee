angular.module 'mkmobile.directives.product', []
.directive 'mkmProduct', ->
  restrict: 'E'
  scope: productData: "="
  templateUrl: '/partials/directives/product.html'
