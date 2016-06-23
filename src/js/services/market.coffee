angular.module 'mkmobile.services.market', []
.factory 'MkmApiMarket', [
  'MkmApi', 'DataCache', 'MkmApiAuth'
  (MkmApi, DataCache, MkmApiAuth) ->
    # search for a product
    search: (query, response) ->
      # if response isn't passed in, create a base object that will be filled later
      response = count: 0, products: [] unless response?
      if query
        # toggle loading flag
        response.loading = yes
        # query the API
#        MkmApi.api.search {search: query, idLanguage: MkmApiAuth.getLanguage(), paging: response.products.length + 1}, (data) =>
        MkmApi.api.search {search: query, idLanguage: MkmApiAuth.getLanguage(), start: response.products.length, maxResults: 100}, (data) =>
          # map localized name
          data.product?.map (val) ->
            val.locName = loc.name for loc in val.localization when parseInt(loc.idLanguage, 10) is MkmApiAuth.getLanguage()
          # update count
          response.count = data._range or data.product?.length or 0
          # merge products
          response.products = response.products.concat data.product if response.count
          # toggle loading flag
          response.loading = no
        , (error) ->
          response.error = error
          response.loading = no
      # return the base object
      response

    # get product data
    product: (idProduct) ->
      response = product: DataCache.product idProduct
      # if there is no (deep) product data in cache, retrieve it!
      if !response.product? or (!response.product.reprint? and response.product.countReprints > 1)
        response.loading = yes
        MkmApi.api.product param1: idProduct, (data) ->
          response.product = DataCache.product idProduct, data.product
          response.loading = no
        , (error) ->
          response.error = error
          response.loading = no
      response

    # get articles for a product
    articles: (id, filter = {}, response) ->
      response = count: 0, articles: [] unless response?
      response.loading = yes
      query = param1: id, start: response.articles.length, maxResults: 100
      query[key] = value for key, value of filter when value
      MkmApi.api.articles query, (data) ->
        response.count = data._range or data.article?.length
        response.articles = response.articles.concat data.article if response.count
        response.loading = no
      , (error) ->
        response.error = error
        response.loading = no
      response

    # search for a user
    findUser: (search, cb) ->
      if search and search.length > 2
        MkmApi.api.users {search}, (data) ->
          cb data.users
        , () -> cb []
      else
        cb []

    # get profile data for a user
    getUser: (idUser) ->
      response = user: DataCache.user idUser
      if !response.user?
        response.loading = yes
        MkmApi.api.user {param1: idUser}, (data) ->
          response.user = DataCache.user idUser, data.user
          response.loading = no
        , (error) ->
          response.error = error
          response.loading = no
      response

    # get articles for a user
    getUserArticles: (idUser, response) ->
      response = count: 0, articles: [] unless response?
      response.loading = yes
      MkmApi.api.userArticles {param1: idUser, start: response.articles.length, maxResults: 100}, (data) ->
        response.count = data._range or data.article?.length
        response.articles = response.articles.concat data.article if response.count
        response.loading = no
      , (error) ->
        response.error = error
        response.loading = no
      response

    # search for a metaproduct
    searchMetaproduct: (search = "") ->
      response = count: 0, products: [], loading: no
      if search.length > 1
        response.loading = yes
        MkmApi.api.metaproducts {search, idLanguage: MkmApiAuth.getLanguage()}, (data) =>
          # cache metaproducts
          data.metaproduct?.map (val) =>
            DataCache.metaproduct val.metaproduct.idMetaproduct, val
          # todo: remove this once metaproducts contain this fields by default
          response.products = data.metaproduct?.splice(0,20).map (val) ->
            for loc in val.metaproduct.localization when parseInt(loc.idLanguage, 10) is MkmApiAuth.getLanguage()
              val.metaproduct.locName = loc.name
            val
          response.count = response.products?.length
          response.loading = no
      response

    # get a metaproduct
    metaproduct: (idMetaproduct, cb) ->
      response = metaproduct: DataCache.metaproduct idMetaproduct
      # if there is no (deep) product data in cache, retrieve it!
      if !response.metaproduct?
        response.loading = yes
        MkmApi.api.metaproduct param1: idMetaproduct, (data) ->
          response.metaproduct = DataCache.metaproduct idMetaproduct, data
          response.loading = no
          cb? response
        , (error) ->
          response.error = error
          response.loading = no
          cb? response
      else
        cb? response
      response
]
