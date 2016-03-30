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
      MkmApi.api.accountRegister @form, =>
        # registration successful
        $translate('register.success').then (text) =>
          alert text
          $state.go 'login'
      , (error) =>
        # registration error
        alert error.data.mkm_error_description
        initCaptcha()

    # load the captcha
    do initCaptcha = =>
      @form.captchaValue = ''
      MkmApi.api.captcha ({captcha: {@captcha, requestKey: @form.captchaRequestKey}}) =>
        @captcha = 'data:image/png;base64,'+atob(@captcha) # todo: remove atob
    @
]
