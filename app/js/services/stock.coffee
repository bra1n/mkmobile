mkmobileServices.factory 'MkmApiStock', [ 'MkmApi', 'MkmApiMarket', 'DataCache', (MkmApi, MkmApiMarket, DataCache) ->
  get: (id, response) ->
    if id? # single article
      response = article: DataCache.article id
      unless response.article? # not in cache
        response.loading = yes
        MkmApi.api.stock {param1: 'article', param2: id}, (data) =>
          response.article = DataCache.article id, data.article
          response.loading = no
          response.product = MkmApiMarket.product response.article.idProduct
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
    response

  update: (article, cb) ->
    request = article:
      idArticle: article.idArticle
      idLanguage: article.language.idLanguage
      comments: article.comments
      amount: article.count
      price: article.price
      condition: article.condition
      isFoil: article.isFoil
      isSigned: article.isSigned
      isAltered: article.isAltered
      isPlayset: article.isPlayset
    MkmApi.api.stockUpdate request, (data) =>
      if data.updatedArticles?.length
        # updated articles receive a new ID, so delete the old cache
        DataCache.article article.idArticle, false
        DataCache.article data.updatedArticles[0].idArticle, data.updatedArticles[0]
        cb?()
    false

  # increase article count
  # todo handle response
  increase: (article, cb) ->
    MkmApi.api.stockAmount {param2: article.idArticle, param3: 'increase', param4: 1}, (data) ->
      console.log data
      cb?()

  # decrease article count
  # todo handle response
  decrease: (article, cb) ->
    MkmApi.api.stockAmount {param2: article.idArticle, param3: 'decrease', param4: 1}, (data) ->
      console.log data
      cb?()
]