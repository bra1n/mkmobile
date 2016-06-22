angular.module 'mkmobile.services.wantslist', []
.factory 'MkmApiWantslist', [ 'MkmApi', 'MkmApiAuth', (MkmApi, MkmApiAuth) ->
  # retrieve wantslists
  get: (idWantslist) ->
    if idWantslist? # single list items
      response = list: {}, loading: yes
      MkmApi.api.wantslist {param1: idWantslist}, (data) =>
        response.list = data.wantslist
        # todo: remove this once metaproducts contain this fields by default
        response.list.item = response.list.item.map (item) ->
          for loc in item[item.type].localization
            item[item.type].locName = loc.name if parseInt(loc.idLanguage, 10) is MkmApiAuth.getLanguage()
          item
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
  update: (idWantslist, card, cb) ->
    request = action: if card.idWant then "editItem" else "addItem"
    type = if card.selected then "product" else "metaproduct"
    type = "want" if card.idWant
    request[type] =
      count: card.count
      wishPrice: card.wishPrice
      idLanguage: card.idLanguage or ""
      minCondition: card.minCondition or ""
      isSigned: card.isSigned or ""
      isFoil: card.isFoil or ""
#      mailAlert: card.mailAlert or true
      isAltered: card.isAltered or ""
      idProduct: card.selected.idProduct or ""
      idMetaproduct: card.metaproduct.idMetaproduct or ""
    MkmApi.api.wantslistUpdate {param1: idWantslist}, request, (data) ->
      cb?(data)

  # add a new article to the stock, will pass any error messages to the callback
  create: (wantslist, cb) ->
    MkmApi.api.wantslistCreate {wantslist}, (data) =>
      cb?(data)

  # rename a wantslist
  rename: (idWantslist, name, cb) ->
    request =
      action: "editWantslist"
      name: name
    MkmApi.api.wantslistUpdate {param1: idWantslist}, request, cb, cb

  # delete a wants list
  delete: (idWantslist, cb) ->
    MkmApi.api.wantslistDelete {param1: idWantslist}, cb

  # search for a metaproduct
  search: (search = "") ->
    response = count: 0, products: [], loading: no
    if search.length > 1
      response.loading = yes
      MkmApi.api.metaproducts {search, idLanguage: MkmApiAuth.getLanguage()}, (data) =>
        # todo: remove this once metaproducts contain this fields by default
        response.products = data.metaproduct?.splice(0,20).map (val) ->
          for loc in val.metaproduct.localization
            val.metaproduct.locName = loc.name if parseInt(loc.idLanguage, 10) is MkmApiAuth.getLanguage()
          val
        response.count = response.products?.length
        response.loading = no
    response
]
