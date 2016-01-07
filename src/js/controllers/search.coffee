# search
angular.module 'mkmobile.controllers.search', []
.controller 'SearchCtrl', [
  '$scope', '$stateParams', 'MkmApiMarket'
  ($scope, $stateParams, MkmApiMarket) ->
    $scope.$watch 'query', (query) ->
      sessionStorage.setItem "search", query
      $scope.searchData = MkmApiMarket.search query
    # init scope vars
    $scope.query = sessionStorage.getItem("search") or ""
    $scope.sort = "enNam"
    $scope.gameId = window.gameId or 1

    # infinite scrolling
    $scope.loadResults = ->
      # don't load more if we already show all of them
      return if $scope.searchData.products.length >= $scope.searchData.count or $scope.searchData.loading
      MkmApiMarket.search $scope.query, $scope.searchData

    # blur the search input
    $scope.blur = ($event) -> elem.blur() for elem in $event.target
]