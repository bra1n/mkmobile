# /buys /sells
angular.module 'mkmobile.controllers.order', []
.controller 'OrderCtrl', ($scope, $stateParams, MkmApiOrder, $window, $state) ->
  $scope.mode = $state.current.name.split(".").pop()
  $scope.idOrder = $stateParams.idOrder
  $window.scrollTo(0,0) if $scope.idOrder?

  $scope.$watch "tab", (status) ->
    sessionStorage.setItem $scope.mode + 'Tab', $scope.tab
    $scope.data = MkmApiOrder.get {mode: $scope.mode, status, idOrder: $scope.idOrder}
  $scope.tab = sessionStorage.getItem($scope.mode + 'Tab') or "bought"

  $scope.loadOrders = ->
    return if $scope.data.orders.length >= $scope.data.count or $scope.data.loading
    MkmApiOrder.get {mode: $scope.mode, status:$scope.tab, response:$scope.data}

  # update order status
  $scope.update = (status) ->
    if status is 'requestCancellation' and !$scope.data.order.showReason
      $scope.data.order.showReason = yes
    else
      MkmApiOrder.update {idOrder:$scope.idOrder, status, reason:$scope.data.order.state.reason}, ->
        $scope.data = MkmApiOrder.get {idOrder: $scope.idOrder}
        $state.go('order.evaluate', {idOrder: $scope.idOrder}) if status is "confirmReception"

  # evaluate order
  $scope.evaluations = MkmApiOrder.getEvaluations()
  $scope.complaints = MkmApiOrder.getComplaints()
  $scope.evaluation = MkmApiOrder.getEvaluation()
  $scope.hideOverlay = true
  $scope.evaluate = ->
    MkmApiOrder.evaluate $scope.idOrder, $scope.evaluation, ->
      $state.go 'order.single', idOrder: $scope.idOrder
