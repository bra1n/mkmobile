angular.module 'mkmobile.directives.order', []
.directive 'mkmOrder', [ 'MkmApiCart', (MkmApiCart) ->
  scope:
    order: "="
    removeArticle: "="
    shippingMethod: "="
  link: (scope) -> scope.countries = MkmApiCart.getCountries()
  restrict: 'E'
  templateUrl: '/partials/directives/order.html'
]