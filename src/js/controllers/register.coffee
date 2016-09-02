# /recover
angular.module 'mkmobile.controllers.register', []
.controller 'RegisterCtrl', (MkmApiCart, $translate, MkmApi, $state) ->
  @form = {}
  @formError = ""
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
      @formError = error.data.post_data_field
      $translate('register.error').then (text) =>
        alert text
      initCaptcha()

  # load the captcha
  do initCaptcha = =>
    @form.captchaValue = ''
    MkmApi.api.captcha ({captcha: {@imgUri, requestKey: @form.captchaRequestKey}}) =>
  @