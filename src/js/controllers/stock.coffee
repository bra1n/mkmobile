# /stock
angular.module 'mkmobile.controllers.stock', []
.controller 'StockCtrl', [
  '$scope', '$location', '$stateParams', 'MkmApiStock'
  ($scope, $location, $stateParams, MkmApiStock) ->
    # selecting an article in stock
    $scope.selected = []
    $scope.select = (id) ->
      if id in $scope.selected
        $scope.selected.splice $scope.selected.indexOf(id), 1
      else
        $scope.selected.push id

    # search logic / loading article data
    $scope.$watch 'query', (query) ->
      $scope.selected = []
      sessionStorage.setItem "searchStock", query
      if !query or $stateParams.articleId
        $scope.data = MkmApiStock.get $stateParams.articleId
      else
        $scope.data = MkmApiStock.search query

    $scope.loadArticles = ->
      unless $scope.data.articles.length >= $scope.data.count or $scope.data.loading
        if !$scope.query or $stateParams.articleId
          MkmApiStock.get $stateParams.articleId, $scope.data
        else
          MkmApiStock.search $scope.query, $scope.data
    $scope.query = sessionStorage.getItem("searchStock") or ""

    # change article counts
    $scope.increase = (articles) -> MkmApiStock.updateBatch articles, 1
    $scope.decrease = (articles) -> MkmApiStock.updateBatch articles, -1

    # edit article stuff
    $scope.languages = MkmApiStock.getLanguages()
    $scope.conditions = MkmApiStock.getConditions()
    $scope.save = -> MkmApiStock.update $scope.data.article, -> $location.path "/stock"

    # blur search input
    $scope.blur = ($event) -> elem.blur() for elem in $event.target
]
