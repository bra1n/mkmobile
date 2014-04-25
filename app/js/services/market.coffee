mkmobileServices.factory 'MkmApiMarket', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  # search for a product
  search: (query, response) ->
    # if response isn't passed in, create a base object that will be filled later
    response = count: 0, products: [] unless response?
    if query
      # toggle loading flag
      response.loading = yes
      # query the API
      MkmApi.api.search {param1: query, param5: response.products.length + 1}, (data) =>
        # cache products - but flag them as shallow caches
        # todo update when search products contain reprint count
        data.product?.map (val) =>
          val._shallow = yes
          DataCache.product val.idProduct, val
        # update count
        response.count = data._range or data.product?.length
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
  product: (id) ->
    response = product: DataCache.product id
    # if there is no (deep) product data in cache, retrieve it!
    if !response.product? or response.product._shallow
      response.loading = yes
      MkmApi.api.product param1: id, (data) =>
        response.product = DataCache.product id, data.product
        response.loading = no
      , (error) ->
        response.error = error
        response.loading = no
    response

  # get articles for a product
  articles: (id, response) ->
    response = count: 0, articles: [] unless response?
    response.loading = yes
    MkmApi.api.articles {param1: id, param2: response.articles.length + 1}, (data) ->
      response.count = data._range or data.article?.length
      response.articles = response.articles.concat data.article if response.count
      response.loading = no
    , (error) ->
      response.error = error
      response.loading = no
    response
]