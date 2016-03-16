# /messages
angular.module 'mkmobile.controllers.message', []
.controller 'MessageCtrl', [
  '$scope', '$stateParams', 'MkmApiMessage', 'MkmApiMarket', '$translate'
  ($scope, $stateParams, MkmApiMessage, MkmApiMarket, $translate) ->
    $scope.unreadCount = MkmApiMessage.count()
    $scope.data = MkmApiMessage.get $stateParams.idUser, -> $scope.unreadCount = MkmApiMessage.count()
    # search for user
    $scope.$watch "search", (search) -> MkmApiMarket.findUser search, (users) ->
      filtered = []
      $scope.users = []
      filtered.push thread.partner.idUser for thread in $scope.data.messages
      $scope.users.push user for user in users when user.idUser not in filtered
    # send a new message
    $scope.send = ->
      MkmApiMessage.send $stateParams.idUser, $scope.message, $scope.data
      $scope.message = ""
      false
    # delete a message
    $scope.delete = (index, threadId, messageId) -> $translate('messages.are_you_sure').then (text) ->
      return unless confirm text
      $scope.data.count--
      $scope.data.messages.splice index, 1
      MkmApiMessage.delete threadId, messageId

    # blur the search input
    $scope.blur = ($event) -> elem.blur() for elem in $event.target
]
