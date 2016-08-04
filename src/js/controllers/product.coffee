# /product
angular.module 'mkmobile.controllers.product', []
.controller 'ProductCtrl', ($stateParams, $state, MkmApiMarket, MkmApiAuth, MkmApiCart, MkmApiStock) ->
  # init vars
  @screen = $stateParams.screen
  @languages = MkmApiStock.getLanguages()
  @conditions = MkmApiStock.getConditions()
  @filter = JSON.parse(sessionStorage.getItem("filter")) or {}

  # get product data
  @productData = MkmApiMarket.product $stateParams.idProduct

  # load articles
  @data = MkmApiMarket.articles $stateParams.idProduct

  # get account
  MkmApiAuth.getAccount ({@account}) => # store account in controller scope

  # infinite scrolling
  @loadArticles = =>
    return if @data.articles.length >= @data.count or @data.loading
    MkmApiMarket.articles $stateParams.idProduct, @filter, @data

  # show overlay
  @show = (screen, event) =>
    event.preventDefault() if @screen and event
    @screen = if @screen is screen then "" else screen
    $stateParams.screen = @screen
    $state.transitionTo $state.current.name, $stateParams, {notify: no, location: 'replace'}

  # reset filter form
  @clearFilter = =>
    if @filter.inUse
      @data = MkmApiMarket.articles $stateParams.idProduct, @filter
    @filter = {}
    sessionStorage.removeItem "filter"

  # use filter
  @applyFilter = =>
    delete @filter.inUse
    @filter.inUse = !!Object.keys(@filter).length
    sessionStorage.setItem "filter", JSON.stringify @filter
    @data = MkmApiMarket.articles $stateParams.idProduct, @filter
    @show ''

  # sell / save a product
  @sell = =>
    method = if @screen is 'sell' then 'create' else 'update'
    @error = ""
    MkmApiStock[method] @article, (@error) =>
      unless @error
        @data = MkmApiMarket.articles $stateParams.idProduct, @filter
        @show ''

  # increase article count
  @add = (article, event) =>
    event.stopPropagation()
    MkmApiStock.updateBatch [article], 1

  # decrease article count
  @remove = (article, event) =>
    event.stopPropagation()
    MkmApiStock.updateBatch [article], -1

  # edit article
  @edit = (@article, event) =>
    @article.idLanguage = @article.language.idLanguage.toString()
    event.stopPropagation()
    @screen = 'edit'

  # reset article
  do @clearArticle = => @article = {idLanguage: "1", condition: "NM", idProduct: $stateParams.idProduct}

  # check if filter has content
  @hasFilter = =>
    return yes for key, value of @filter when value
    no

  # add article to cart
  @addToCart = (article, event) =>
    event.stopPropagation()
    if MkmApiAuth.checkLogin()
      # reduce the amount before receiving the server response to prevent adding too many to the cart
      article.count--
      MkmApiCart.add article.idArticle
  @
