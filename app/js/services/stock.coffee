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
      count: article.count
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
  increase: (article, cb) ->
    article.loading = yes
    MkmApi.api.stockAmount {idArticle: article.idArticle, action: 'increase', amount: 1}, (data) ->
      DataCache.article article.idArticle, data.article
      article.count++
      article.loading = no
      cb?()

  # decrease article count
  decrease: (article, cb) ->
    article.loading = yes
    MkmApi.api.stockAmount {idArticle: article.idArticle, action: 'decrease', amount: 1}, (data) ->
      DataCache.article article.idArticle, data.article
      article.count--
      article.loading = no
      cb?()

  search: (query, response) ->
    response = count: 0, articles: [] unless response?
    response.loading = yes
    MkmApi.api.stockSearch {param2: query, param3: response.articles.length + 1}, (data) =>
      response.count = data._range or data.article?.length
      response.articles = response.articles.concat data.article.map((val) => DataCache.article val.idArticle, val) if response.count
      response.loading = no
    response

  getLanguages: -> [
    {id: 1, label: "EN"}
    {id: 2, label: "FR"}
    {id: 3, label: "DE"}
    {id: 4, label: "SP"}
    {id: 5, label: "IT"}
    {id: 6, label: "CH"}
    {id: 7, label: "JP"}
    {id: 8, label: "PT"}
    {id: 9, label: "RU"}
    {id: 10, label: "KO"}
    {id: 11, label: "TW"}
  ]

  getGradings: -> [
    "MT","NM","EX","GD","LP","PL","PO"
  ]
]