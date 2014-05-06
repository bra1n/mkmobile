mkmobileServices.factory 'MkmApiStock', [ 'MkmApi', 'MkmApiMarket', 'DataCache', (MkmApi, MkmApiMarket, DataCache) ->
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
    response

  update: (article, cb) ->
    request = article:
      idArticle: article.idArticle
      idLanguage: article.language.idLanguage
      comments: article.comments
      count: article.amount or article.count
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
    {value: 1, label: "English"}
    {value: 2, label: "French"}
    {value: 3, label: "German"}
    {value: 4, label: "Spanish"}
    {value: 5, label: "Italian"}
    {value: 6, label: "Chinese"}
    {value: 7, label: "Japanese"}
    {value: 8, label: "Portuguese"}
    {value: 9, label: "Russian"}
    {value: 10, label: "Korean"}
    {value: 11, label: "T-Chinese"}
  ]

  getGradings: -> [
    {value: "MT", label: "Mint"}
    {value: "NM", label: "Near Mint"}
    {value: "EX", label: "Excellent"}
    {value: "GD", label: "Good"}
    {value: "LP", label: "Light Played"}
    {value: "PL", label: "Played"}
    {value: "PO", label: "Poor"}
  ]
]