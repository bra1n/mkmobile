mkmobileServices.factory 'MkmApiCart', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  # get the cart object (optionally filtered by ID)
  # todo replace seller.username with idOrder
  get: (id, cb) ->
    response = cart: DataCache.cart(), address: DataCache.address(), balance: DataCache.balance()
    unless response.cart?
      # fetch the cart
      response.loading = yes
      MkmApi.api.shoppingcart {}, (data) =>
        response.loading = no
        response.balance = DataCache.balance data.accountBalance
        response.cart = DataCache.cart data.shoppingCart
        response.address = DataCache.address data.shippingAddress
        response.order = order for order in response.cart when order.idReservation is parseInt(id,10) if id?
        cb?(response)
      , (error) =>
        response.error = error
        response.loading = no
    else
      # cart already there, yay!
      response.order = order for order in response.cart when order.idReservation is parseInt(id,10) if id?
      cb?(response)
    response

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
      data = data.shoppingCart # todo needs to be fixed in the api
      DataCache.cart data.shoppingCart
      DataCache.address data.shippingAddress
      DataCache.account data.account
      DataCache.balance data.accountBalance
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
      data = data.shoppingCart # todo needs to be fixed in the api
      DataCache.cart data.shoppingCart or []
      DataCache.address data.shippingAddress
      DataCache.account data.account
      cb?()

  # checkout
  checkout: (cb) ->
    MkmApi.api.checkout {}, (data) ->
      DataCache.order(order.idOrder, order) for order in data.order
      DataCache.cart []
      cb?()

  # change the shipping address
  shippingAddress: (address) ->
    DataCache.address address
    MkmApi.api.shippingAddress address, (data) =>
      console.log data

  getCountries: ->
    [
      { code:"AT", label:"Austria"        }
      { code:"BE", label:"Belgium"        }
      { code:"BG", label:"Bulgaria"       }
      { code:"CH", label:"Switzerland"    }
      { code:"CY", label:"Cyprus"         }
      { code:"CZ", label:"Czech Republic" }
      { code:"D",  label:"Germany"        }
      { code:"DK", label:"Denmark"        }
      { code:"EE", label:"Estonia"        }
      { code:"ES", label:"Spain"          }
      { code:"FI", label:"Finland"        }
      { code:"FR", label:"France"         }
      { code:"GB", label:"Great Britain"  }
      { code:"GR", label:"Greece"         }
      { code:"HR", label:"Croatia"        }
      { code:"HU", label:"Hungary"        }
      { code:"IE", label:"Ireland"        }
      { code:"IT", label:"Italy"          }
      { code:"LI", label:"Liechtenstein"  }
      { code:"LT", label:"Lithuania"      }
      { code:"LU", label:"Luxembourg"     }
      { code:"LV", label:"Latvia"         }
      { code:"MT", label:"Malta"          }
      { code:"NL", label:"Netherlands"    }
      { code:"NO", label:"Norway"         }
      { code:"PL", label:"Poland"         }
      { code:"PT", label:"Portugal"       }
      { code:"RO", label:"Romania"        }
      { code:"SE", label:"Sweden"         }
      { code:"SI", label:"Slovenia"       }
      { code:"SK", label:"Slovakia"       }
    ]
]