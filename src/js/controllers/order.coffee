# /buys /sells
angular.module 'mkmobile.controllers.order', []
.controller 'OrderCtrl', [
  '$scope', '$location', '$stateParams', 'MkmApiOrder', '$window'
  ($scope, $location, $stateParams, MkmApiOrder, $window) ->
    $scope.mode = $location.path().substr(1).replace /^(.*?)\/.*?$/, '$1'
    $scope.orderId = $stateParams.orderId
    $window.scrollTo(0,0) if $scope.orderId?
    $scope.$watch "tab", (status) ->
      sessionStorage.setItem $scope.mode + 'Tab', $scope.tab
      $scope.data = MkmApiOrder.get {mode: $scope.mode, status, orderId: $scope.orderId}
    $scope.tab = sessionStorage.getItem($scope.mode + 'Tab') or "bought"
    $scope.loadOrders = ->
      return if $scope.data.orders.length >= $scope.data.count or $scope.data.loading
      MkmApiOrder.get {mode: $scope.mode, status:$scope.tab, response:$scope.data}
    # update order status
    $scope.update = (status) ->
      if status is 'requestCancellation' and !$scope.data.order.showReason
        $scope.data.order.showReason = yes
      else
        MkmApiOrder.update {orderId:$scope.orderId, status, reason:$scope.data.order.state.reason}, ->
          $scope.data = MkmApiOrder.get {orderId: $scope.orderId}
          $location.path('/'+$scope.mode+'/'+$scope.orderId+'/evaluate') if status is "confirmReception"
      false
    # evaluate order
    $scope.evaluations = MkmApiOrder.getEvaluations()
    $scope.complaints = MkmApiOrder.getComplaints()
    $scope.evaluation = MkmApiOrder.getEvaluation()
    $scope.hideOverlay = 0
    $scope.evaluate = -> MkmApiOrder.evaluate $scope.orderId, $scope.evaluation, -> $location.path "/"+$scope.mode+"/"+$scope.orderId
]
