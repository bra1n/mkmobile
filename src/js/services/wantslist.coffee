angular.module 'mkmobile.services.wantslist', []
.factory 'MkmApiWantslist',(MkmApi) ->
  # retrieve wantslists
  get: (idWantslist) ->
    if idWantslist? # single list items
      response = list: {}, loading: yes
      MkmApi.api.wantslist {param1: idWantslist}, (data) =>
        response.list = data.wantslist
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
    type = if card.product then "product" else "metaproduct"
    type = "want" if card.idWant
    request[type] =
      count: card.count
      idWant: card.idWant or ""
      wishPrice: card.wishPrice or ""
      idLanguage: card.idLanguage or ""
      minCondition: card.minCondition or ""
      isSigned: card.isSigned or ""
      isFoil: card.isFoil or ""
      mailAlert: card.mailAlert
      isAltered: card.isAltered or ""
      idProduct: (card.product or {}).idProduct or ""
      idMetaproduct: card.metaproduct.idMetaproduct or ""
    MkmApi.api.wantslistUpdate {param1: idWantslist}, request, cb

  # add a new article to the stock, will pass any error messages to the callback
  create: (wantslist, cb) ->
    MkmApi.api.wantslistCreate {wantslist}, cb

  # remove a list of articles from a wantlist
  remove: (idWantslist, items, cb) ->
    request =
      action: "deleteItem"
      want: items
    MkmApi.api.wantslistUpdate {param1: idWantslist}, request, cb

  # rename a wantslist
  rename: (idWantslist, name, cb) ->
    request =
      action: "editWantslist"
      name: name
    MkmApi.api.wantslistUpdate {param1: idWantslist}, request, cb, cb

  # delete a wants list
  delete: (idWantslist, cb) ->
    MkmApi.api.wantslistDelete {param1: idWantslist}, cb