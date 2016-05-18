# /wantslist
angular.module 'mkmobile.controllers.wantslist', []
.controller 'WantslistCtrl', [
  'MkmApiWantslist', '$stateParams', '$translate'
  (MkmApiWantslist, $stateParams, $translate) ->
    @data = MkmApiWantslist.get $stateParams.idWantsList
    @create = ->
      MkmApiWantslist.create @name, =>
        # add list to data
    @update = (list) ->
      MkmApiWantslist.update list
      list.edit = 0
    @delete = (list) =>
      $translate('wantslist.confirm', list).then (text) =>
        return unless confirm text
        MkmApiWantslist.delete list
        list.deleted = 1
        @data.count--
        console.log "deleted", list
    @
]
