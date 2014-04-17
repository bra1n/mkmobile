mkmobileServices.factory 'DataCache', ['$cacheFactory', ($cacheFactory) ->
  # all glory to the mighty cache object
  cache =
    product: $cacheFactory 'products', capacity: 500
    article: $cacheFactory 'article', capacity: 1000
    cart: $cacheFactory 'cart', capacity: 1
    account: $cacheFactory 'account', capacity: 4
    order: $cacheFactory 'order', capacity: 1000
  product: (id, data) ->
    cache.product.put(id, data) if data?
    cache.product.get(id) if id?
  article: (id, data) ->
    cache.article.put(id, data) if data?
    cache.article.remove(id) if data is false
    cache.article.get(id) if id?
  cart: (data) ->
    cache.cart.put('cart', data) if data?
    cache.cart.get('cart')
  account: (data) ->
    cache.account.put('account', data) if data?
    cache.account.get('account')
  cartCount: (count) ->
    cache.account.put('articlesInShoppingCart', count) if count?
    cache.account.get('articlesInShoppingCart')
  messageCount: (count) ->
    cache.account.put('unreadMessages', count) if count?
    cache.account.get('unreadMessages')
  address: (data) ->
    cache.account.put('address', data) if data?
    cache.account.get('address')
  order: (id, data) ->
    cache.order.put(id, data) if data?
    cache.order.get(id) if id?
]