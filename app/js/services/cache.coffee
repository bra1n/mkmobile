mkmobileServices.factory 'DataCache', ['$cacheFactory', ($cacheFactory) ->
  # all glory to the mighty cache object
  caches =
    product: $cacheFactory 'products', capacity: 500
    article: $cacheFactory 'article', capacity: 1000
    cart: $cacheFactory 'cart', capacity: 1
    account: $cacheFactory 'account', capacity: 5
    order: $cacheFactory 'order', capacity: 1000
  reset: ->
    cache.removeAll() for index, cache of caches
  product: (id, data) ->
    caches.product.put(id, data) if data?
    caches.product.get(id) if id?
  article: (id, data) ->
    caches.article.put(id, data) if data?
    caches.article.remove(id) if data is false
    caches.article.get(id) if id?
  cart: (data) ->
    caches.cart.put('cart', data) if data?
    caches.cart.get('cart')
  account: (data) ->
    caches.account.put('account', data) if data?
    caches.account.get('account')
  balance: (balance) ->
    caches.account.put('balance', balance) if balance?
    caches.account.get('balance')
  cartCount: (count) ->
    caches.account.put('articlesInShoppingCart', count) if count?
    caches.account.get('articlesInShoppingCart')
  messageCount: (count) ->
    caches.account.put('unreadMessages', count) if count?
    caches.account.get('unreadMessages')
  address: (data) ->
    caches.account.put('address', data) if data?
    caches.account.get('address')
  order: (id, data) ->
    caches.order.put(id, data) if data?
    caches.order.get(id) if id?
]