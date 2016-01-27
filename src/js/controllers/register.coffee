# /recover
angular.module 'mkmobile.controllers.register', []
.controller 'RegisterCtrl', [
  'MkmApiCart', '$translate', 'MkmApi', '$state'
  (MkmApiCart, $translate, MkmApi, $state) ->
    @form = {}
    @steps = []
    @step = 0
    @countries = MkmApiCart.getCountries()

    @go = (to) => # don't go to a step if a previous one still has errors
      return for step, index in @steps when step.$invalid and index < to
      @step = to
    @register = =>
      console.log @form
      MkmApi.api.accountRegister @form, =>
        # registration successful
        $translate('register.success').then (text) =>
          alert text
          $state.go 'login'
      , (error) =>
        # registration error
        initCaptcha()

    # load the captcha
    do initCaptcha = =>
      MkmApi.api.captcha ({captcha: {@captcha, requestKey: @form.captchaRequestKey}}) =>
        # @todo use real data once available
        @captcha = 'data:image/png;base64,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'
    @
]
