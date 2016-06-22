# /wantslist
angular.module 'mkmobile.controllers.wantslist', []
.controller 'WantslistCtrl', [
  'MkmApiStock', 'MkmApiWantslist', '$stateParams', '$translate'
  (MkmApiStock, MkmApiWantslist, $stateParams, $translate) ->
    @languages = MkmApiStock.getLanguages()
    @conditions = MkmApiStock.getConditions()
    @data = MkmApiWantslist.get $stateParams.idWantslist
    @cardname = "" # suggestions search field
    @current = {} # current card in add screen
    @selected = [] # array of selected cards on a wants list

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

    # search for a metaproduct to add to wantslist
    @search = =>
      @suggestions = MkmApiWantslist.search @cardname

    # select a suggested metaproduct for adding to the wantslist
    @select = (card) =>
      @current.metaproduct = card.metaproduct
      @current.product = card.product
      @current.selected = ""
      @suggestions = products: []
      @cardname = ""

    # add / update an item for the current wantslist
    @item = () =>
      @error = no
      MkmApiWantslist.update $stateParams.idWantslist, @current, (data) =>
        if data.errors
          @error = yes
        else
          @data.list = data.wantslist
          @screen = ""

    # check a checkbox next to an item on a wantslist
    @check = (item) =>
      if item in @selected
        @selected.splice @selected.indexOf(item), 1
      else
        @selected.push item

    # edit selected wantslist item
    @edit = =>
      @current = @selected[0]
      @screen = "edit"

    # remove a bunch of items from a wantslist
    @remove = =>
      console.log @selected

    @
]
