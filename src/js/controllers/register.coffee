# /recover
angular.module 'mkmobile.controllers.register', []
.controller 'RegisterCtrl', [
  'MkmApiCart', '$translate'
  (MkmApiCart, $translate) ->
    @steps = []
    @step = 0
    @countries = MkmApiCart.getCountries()
    @go = (step) ->
      @step = step unless @steps[step-1]?.$invalid
    @
]