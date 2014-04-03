mkmobileServices.factory 'DataCache', ['$cacheFactory', ($cacheFactory) ->
  # all glory to the mighty cache object
  cache =
    product: $cacheFactory 'products', capacity: 500
    article: $cacheFactory 'article', capacity: 1000
    cart: $cacheFactory 'cart', capacity: 2
    user: $cacheFactory 'user', capacity: 1
    order: $cacheFactory 'order', capacity: 1000
  product: (id, data) ->
    cache.product.put(id, data) if data?
    cache.product.get(id) if id?
  article: (id, data) ->
    # todo take out once the api returns the right format
    if data?
      data.price = parseFloat(data.price) if data.price?
      data.count = parseInt(data.count, 10) if data.count?
    cache.article.put(id, data) if data?
    cache.article.remove(id) if data is false
    cache.article.get(id) if id?
  cart: (data) ->
    if data?
      # todo replace with API field for "total count per seller"
      for seller,index in data
        count = 0
        count += parseInt(article.count, 10) for article in seller.article
        data[index].totalCount = count
      # end of replace
      cache.cart.put('cart', data) if data?
    cache.cart.get('cart')
  # cartCount is handled independently of cart contents
  cartCount: (count) ->
    cache.cart.put('count', count) if count?
    cache.cart.get('count') or 0
  user: (data) ->
    cache.user.put(1, data) if data?
    cache.user.get(1) or []
  order: (id, data) ->
    cache.order.put(id, data) if data?
    cache.order.get(id) if id?
]