class ServiceMarket
  constructor: ({@api, @cache}) ->

  # search for a product
  search: (query, response) ->
    # if response isn't passed in, create a base object that will be filled later
    response = count: 0, products: [] unless response?
    if query
      # toggle loading flag
      response.loading = yes
      # query the API
      @api.search {param1: query, param5: response.products.length + 1}, (data) =>
        # cache products
        data.product?.map (val) => @cache.product val.idProduct, val
        # update count
        response.count = data._range or data.product?.length
        # merge products
        response.products = response.products.concat data.product if response.count
        # toggle loading flag
        response.loading = no
    # return the base object
    response

  # get product data
  product: (id) ->
    response = product: @cache.product id
    unless response.product? # no product data in cache, retrieve it!
      @api.product param1: id, (data) =>
        response.product = @cache.product id, data.product
    response

  # get articles for a product
  articles: (id, response) ->
    response = count: 0, articles: [] unless response?
    response.loading = yes
    @api.articles {param1: id, param2: response.articles.length + 1}, (data) ->
      response.count = data._range or data.article?.length
      response.articles = response.articles.concat data.article if response.count
      response.loading = no
    response