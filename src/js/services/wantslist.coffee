angular.module 'mkmobile.services.wantslist', []
.factory 'MkmApiWantslist', [ 'MkmApi', (MkmApi) ->
  # retrieve wantslists
  get: (idWantslist) ->
    if idWantslist? # single list items
      response = items: [], loading: yes
      MkmApi.api.wantslist {param1: idWantslist}, (data) =>
        response.items = data.want
        response.loading = no
      , ->
        response.error = yes
        response.loading = no
    else # fetch all lists
      response = count: 0, lists: []
      response.loading = yes
      MkmApi.api.wantslist (data) =>
        response.count = data._range or data.wantslist?.length
        response.lists = data.wantslist
        response.loading = no
      , ->
        response.error = yes
        response.loading = no
    response

  # change a wantslist
  update: (wantslist, cb) ->
#    request = article:
#      idArticle: article.idArticle
#      idLanguage: article.idLanguage or article.language.idLanguage
#      comments: article.comments
#      count: article.amount or article.count
#      price: article.price
#      condition: article.condition
#      isFoil: article.isFoil
#      isSigned: article.isSigned
#      isAltered: article.isAltered
#      isPlayset: article.isPlayset
#      isFirstEd: article.isFirstEd
#    MkmApi.api.stockUpdate request, (data) =>
#      if data.updatedArticles?.length
#        # updated articles receive a new ID, so delete the old cache
#        DataCache.article article.idArticle, false
#        DataCache.article data.updatedArticles[0].idArticle, data.updatedArticles[0]
#        cb?()
    false

  # add a new article to the stock, will pass any error messages to the callback
  create: (name, cb) ->
#    MkmApi.api.stockCreate {article}, (data) =>
#      if data.inserted?.length and data.inserted[0].success
#        DataCache.article data.inserted[0].idArticle, data.inserted[0]
#        cb?()
#      else
#        cb? data.inserted[0].error
    false

  delete: (list, cb) ->
    false
]
