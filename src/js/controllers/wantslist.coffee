# /wantslist
angular.module 'mkmobile.controllers.wantslist', []
.controller 'WantslistCtrl', [
  'MkmApiStock', 'MkmApiWantslist', 'MkmApiMarket', '$stateParams', '$translate'
  (MkmApiStock, MkmApiWantslist, MkmApiMarket, $stateParams, $translate) ->
    @languages  = MkmApiStock.getLanguages()
    @conditions = MkmApiStock.getConditions()
    @data       = MkmApiWantslist.get $stateParams.idWantslist # load wantslist / wantslist items
    @cardname   = "" # suggestions search field
    @selected   = [] # array of selected cards on a wants list

    ### UI methods ###
    # search for a metaproduct to add to wantslist
    @search = =>
      @suggestions = MkmApiMarket.searchMetaproduct @cardname

    # select a suggested metaproduct for adding to the wantslist
    @select = (card) =>
      @current.metaproduct = card.metaproduct
      @current.metaprintings = card.product
      @current.product = ""
      @suggestions = products: []
      @cardname = ""

    # check a checkbox next to an item on a wantslist
    @check = (item) =>
      if item in @selected
        @selected.splice @selected.indexOf(item), 1
      else
        @selected.push item

    # add a wantslist item
    @add = =>
      @current = {mailAlert: "true", minCondition: "PO"}
      @cardform.$setUntouched()
      @screen = 'add'

    # edit selected wantslist item -> transform selected wantslist to something we can edit
    @edit = =>
      # make a copy
      @current = angular.copy @selected[0]
      # clear wishPrice if 0 or null
      @current.wishPrice = "" unless @current.wishPrice
      # transform booleans to string
      for field in ["mailAlert", "isFoil", "isSigned", "isAltered"]
        @current[field] = if typeof @current[field] is "boolean" then @current[field].toString() else ""
      # get metaproduct printings and keep selected expansion, if present
      MkmApiMarket.metaproduct @current[@current.type].idMetaproduct, (data) =>
        @current.metaproduct or= data.metaproduct.metaproduct
        @current.metaprintings = data.metaproduct.product
      @screen = "edit"

    ### API methods ###
    # add / update an item for the current wantslist
    @update = () =>
      @error = no
      MkmApiWantslist.update $stateParams.idWantslist, @current, (data) =>
        if data.errors
          @error = yes
        else
          @data.list = data.wantslist
          @selected = []
          @screen = ""

    # remove a bunch of items from a wantslist
    @remove = =>
      items = []
      items.push {idWant: item.idWant} for item in @selected
      MkmApiWantslist.remove $stateParams.idWantslist, items, (data) =>
        @selected = []
        @data.list = data.wantslist
        console.log data

    # create new wantslist
    @create = ->
      MkmApiWantslist.create {name: @name, idGame: window.gameId or '1'}, (data) =>
        unless data.error?
          @name = ""
          @data.lists.push data.wantslist.pop()
          @data.count++

    # update wantslist name
    @rename = (list) ->
      MkmApiWantslist.rename list.idWantslist, list.name, =>
        list.edit = 0

    # delete a wants list
    @delete = (list) =>
      $translate('wantslist.confirm', list).then (text) =>
        return unless confirm text
        MkmApiWantslist.delete list.idWantslist
        list.deleted = 1
        @data.count--

    @
]
