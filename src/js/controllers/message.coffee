# /messages
angular.module 'mkmobile.controllers.message', []
.controller 'MessageCtrl', ($scope, $stateParams, MkmApiMessage, MkmApiMarket, $translate) ->
  @unreadCount = MkmApiMessage.count()
  @data = MkmApiMessage.get $stateParams.idUser, => @unreadCount = MkmApiMessage.count()
  @users = {}

  # search for user
  $scope.$watch (() => @searchUser), (search) =>
    @users.loading = yes
    MkmApiMarket.findUser search, (@users) =>

  # send a new message
  @send = =>
    MkmApiMessage.send $stateParams.idUser, @message, @data
    @message = ""
    @form.$setUntouched()
    false

  # delete a message
  @delete = (index, threadId, messageId) -> $translate('messages.are_you_sure').then (text) =>
    return unless confirm text
    @data.count--
    @data.messages.splice index, 1
    MkmApiMessage.delete threadId, messageId

  # blur the search input
  @blur = ($event) -> elem.blur() for elem in $event.target

  @
