mkmobileServices.factory 'MkmApiCart', [ 'MkmApi', 'DataCache', '$filter', (MkmApi, DataCache, $filter) ->
  # get the cart object (optionally filtered by ID)
  get: (id, cb) ->
    response =
      cart: DataCache.cart()
      address: DataCache.address()
      balance: DataCache.balance()
      account: DataCache.account()
    unless response.cart?
      # fetch the cart
      response.loading = yes
      MkmApi.api.cart {}, (data) =>
        @cache data
        response.loading = no
        response.account = DataCache.account()
        response.balance = DataCache.balance()
        response.cart = DataCache.cart()
        response.address = DataCache.address()
        response.order = order for order in response.cart when order.idReservation is parseInt(id,10) if id?
        @getShippingMethods response
        cb?(response)
      , (error) =>
        response.error = error
        response.loading = no
    else
      # cart already there, yay!
      response.order = order for order in response.cart when order.idReservation is parseInt(id,10) if id?
      @getShippingMethods response
      cb?(response)
    response

  # augments a single order with the available shipping methods
  getShippingMethods: (response) ->
    return unless response.cart.length is 1 or response.order? # check if it's a single order
    createOption = (method) ->
      value: method.idShippingMethod
      label: method.name+" - "+$filter('currency')(method.price,'€')
      group: if method.isInsured then "Insured" else "Uninsured"
    order = response.order or response.cart[0]
    order.shippingMethods = [ createOption order.shippingMethod ]
    MkmApi.api.shippingMethod {param2: order.idReservation}, (data) ->
      order.shippingMethods = []
      order.shippingMethods.push createOption method for method in data.availableMethod

  # get number of articles in cart
  count: ->
    if DataCache.cart()?
      # we have cart contents, calculate the count
      count = 0
      count += parseInt(seller.articleCount, 10) for seller in DataCache.cart()
      DataCache.cartCount count
    DataCache.cartCount()

  # get total sum of cart
  sum: ->
    sum = 0
    if DataCache.cart()?
      # we have cart contents, calculate the sum
      for seller in DataCache.cart()
        sum += seller.totalValue
    sum

  # add article to cart
  add: (article, cb) ->
    request =
      action: "add"
      article:
        idArticle: article
        amount: 1
    MkmApi.api.cartUpdate request, (data) =>
      @cache data
      cb?()

  # remove article(s) from cart
  # to remove multiple ones, pass in idArticle as {id: amount, id2: amount2, etc.} object
  remove: (articles, cb) ->
    request = action: "remove"
    if typeof articles is "object"
      request.article = []
      request.article.push {idArticle, amount} for idArticle, amount of articles
    else
      request.article = {idArticle:articles, amount: 1}
    MkmApi.api.cartUpdate request, (data) =>
      @cache data
      cb?()

  # cache cart data
  cache: (data) ->
    DataCache.cart data.shoppingCart
    if data.account?
      DataCache.account data.account
      DataCache.balance data.account.accountBalance
    DataCache.address data.shippingAddress

  # checkout
  checkout: (cb) ->
    MkmApi.api.checkout {}, (data) ->
      DataCache.order(order.idOrder, order) for order in data.order
      DataCache.cart []
      if data.account?
        DataCache.account data.account
        DataCache.balance data.account.accountBalance
      cb?()

  # change the shipping address
  shippingAddress: (address, cb) ->
    MkmApi.api.shippingAddress address, (data) =>
      @cache data
      cb?()

  # change the shipping method
  shippingMethod: (order)  ->
    request =
      orderId: order.idReservation
      idShippingMethod: order.shippingMethod.idShippingMethod
    MkmApi.api.shippingMethodUpdate request, (data) =>
      @cache data
      newOrder = thatOrder for thatOrder in data.shoppingCart when thatOrder.idReservation is order.idReservation
      order.shippingMethod = newOrder.shippingMethod
      order.totalValue = newOrder.totalValue

  getCountries: -> [
    { value:"AT", label:"Austria"        }
    { value:"BE", label:"Belgium"        }
    { value:"BG", label:"Bulgaria"       }
    { value:"CH", label:"Switzerland"    }
    { value:"CY", label:"Cyprus"         }
    { value:"CZ", label:"Czech Republic" }
    { value:"D",  label:"Germany"        }
    { value:"DK", label:"Denmark"        }
    { value:"EE", label:"Estonia"        }
    { value:"ES", label:"Spain"          }
    { value:"FI", label:"Finland"        }
    { value:"FR", label:"France"         }
    { value:"GB", label:"Great Britain"  }
    { value:"GR", label:"Greece"         }
    { value:"HR", label:"Croatia"        }
    { value:"HU", label:"Hungary"        }
    { value:"IE", label:"Ireland"        }
    { value:"IT", label:"Italy"          }
    { value:"LI", label:"Liechtenstein"  }
    { value:"LT", label:"Lithuania"      }
    { value:"LU", label:"Luxembourg"     }
    { value:"LV", label:"Latvia"         }
    { value:"MT", label:"Malta"          }
    { value:"NL", label:"Netherlands"    }
    { value:"NO", label:"Norway"         }
    { value:"PL", label:"Poland"         }
    { value:"PT", label:"Portugal"       }
    { value:"RO", label:"Romania"        }
    { value:"SE", label:"Sweden"         }
    { value:"SI", label:"Slovenia"       }
    { value:"SK", label:"Slovakia"       }
  ]
]