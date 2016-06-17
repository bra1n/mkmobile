# /wantslist
angular.module 'mkmobile.controllers.wantslist', []
.controller 'WantslistCtrl', [
  'MkmApiStock', 'MkmApiWantslist', '$stateParams', '$translate'
  (MkmApiStock, MkmApiWantslist, $stateParams, $translate) ->
    @languages = MkmApiStock.getLanguages()
    @conditions = MkmApiStock.getConditions()
    @data = MkmApiWantslist.get $stateParams.idWantsList
    @name = $stateParams.idWantsList # todo: should be wantslist name
    @cardname = "" # suggestions search field
    @current = {} # currentl card in add screen
    @selected = [] # array of selected cards on a wants list

    # create new wantslist
    @create = ->
      MkmApiWantslist.create {name: @name, idGame: window.gameId or '1'}, (data) =>
        unless data.error?
          @data.lists = data.wantslist
          @data.count = data.wantslist.length

    # update wantslist name
    @update = (list) ->
#      MkmApiWantslist.update list
      list.edit = 0

    # delete a wants list
    @delete = (list) =>
      $translate('wantslist.confirm', list).then (text) =>
        return unless confirm text
        MkmApiWantslist.delete list.idWantsList
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
      MkmApiWantslist.update $stateParams.idWantsList, @current, (data) =>
        console.log data

    @
]
