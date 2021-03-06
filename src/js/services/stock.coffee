angular.module 'mkmobile.services.stock', []
.factory 'MkmApiStock', (MkmApi, MkmApiMarket, DataCache) ->
  # retrieve one or more articles
  get: (id, response) ->
    if id? # single article
      response = article: DataCache.article id
      unless response.article? # not in cache
        response.loading = yes
        MkmApi.api.stock {param1: 'article', param2: id}, (data) =>
          response.article = DataCache.article id, data.article
          response.loading = no
          response.product = product: DataCache.product data.product.idProduct, data.product
        , ->
          response.error = yes
          response.loading = no
      else # product loading
        response.product = MkmApiMarket.product response.article.idProduct
    else # fetch all articles
      response = count: 0, articles: [] unless response?
      response.loading = yes
      MkmApi.api.stock {param1: response.articles.length + 1}, (data) =>
        response.count = data._range or data.article?.length
        response.articles = response.articles.concat data.article.map((val) => DataCache.article val.idArticle, val) if response.count
        response.loading = no
      , ->
        response.error = yes
        response.loading = no
    response

  update: (article, cb) ->
    request = article:
      idArticle: article.idArticle
      idLanguage: article.idLanguage or article.language.idLanguage
      comments: article.comments
      count: article.amount or article.count
      price: article.price
      condition: article.condition
      isFoil: article.isFoil
      isSigned: article.isSigned
      isAltered: article.isAltered
      isPlayset: article.isPlayset
      isFirstEd: article.isFirstEd
    MkmApi.api.stockUpdate request, (data) =>
      if data.updatedArticles?.length
        # updated articles receive a new ID, so delete the old cache
        DataCache.article article.idArticle, false
        DataCache.article data.updatedArticles[0].idArticle, data.updatedArticles[0]
        cb?()
    false

  # add a new article to the stock, will pass any error messages to the callback
  create: (article, cb) ->
    MkmApi.api.stockCreate {article}, (data) =>
      if data.inserted?.length and data.inserted[0].success
        DataCache.article data.inserted[0].idArticle, data.inserted[0]
        cb?()
      else
        cb? data.inserted[0].error
    false

  # increase/decrease article count
  updateBatch: (articles, direction) ->
    request =
      action: if direction > 0 then 'increase' else 'decrease'
      article: []
    request.article.push {idArticle: article.idArticle, amount: 1} for article in articles
    MkmApi.api.stockUpdate request, (data) ->
      DataCache.article article.idArticle, article for article in data.article
      article.count += direction for article in articles

  # search in articles
  search: (query, response) ->
    response = count: 0, articles: [] unless response?
    response.loading = yes
    MkmApi.api.stockSearch {param2: query}, (data) =>
      response.count = data._range or data.article?.length
      response.articles = response.articles.concat data.article.map((val) => DataCache.article val.idArticle, val) if response.count
      response.loading = no
    response

  getLanguages: -> [1..11]
  getConditions: -> ["MT","NM","EX","GD","LP","PL","PO"]