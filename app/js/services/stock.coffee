class ServiceStock
  constructor: ({@api, @cache}) ->

  get: (id, response) ->
    if id? # single article
      response = article: @cache.article id
      unless response.article? # not in cache
        response.loading = yes
        @api.stock {param1: 'article', param2: id}, (data) =>
          response.article = @cache.article id, data.article
          response.loading = no
          response.product = @loadProduct(response.article.idProduct)
        , ->
          response.error = yes
          response.loading = no
      else # product loading
        response.product = @loadProduct(response.article.idProduct)
    else # fetch all articles
      response = count: 0, articles: [] unless response?
      response.loading = yes
      @api.stock {param1: response.articles.length + 1}, (data) =>
        response.count = data._range or data.article?.length
        response.articles = response.articles.concat data.article.map((val) => @cache.article val.idArticle, val) if response.count
        response.loading = no
    response

  # todo take out once article contains product entity
  loadProduct: (id) ->
    response = product: @cache.product id
    unless response.product? # no product data in cache, retrieve it!
      @api.product param1: id, (data) =>
        response.product = @cache.product id, data.product
    response

  update: (article, cb) ->
    request = article:
      idArticle: article.idArticle
      language: article.language.idLanguage
      comments: article.comments
      amount: article.count
      price: article.price
      condition: article.condition
      isFoil: article.isFoil
      isSigned: article.isSigned
      isAltered: article.isAltered
      isPlayset: article.isPlayset
    @api.stockUpdate request, (data) =>
      if data.updatedArticles?.length
        # updated articles receive a new ID, so delete the old cache
        @cache.article article.idArticle, false
        @cache.article data.updatedArticles[0].idArticle, data.updatedArticles[0]
        cb?()