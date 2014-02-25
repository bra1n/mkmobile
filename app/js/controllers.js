// Generated by CoffeeScript 1.7.1
var mkmobileControllers;

mkmobileControllers = angular.module('mkmobileControllers', []);

mkmobileControllers.controller('SearchCtrl', [
  '$scope', '$routeParams', '$location', 'MkmApi', 'DataCache', function($scope, $routeParams, $location, MkmApi, DataCache) {
    $scope.search = function() {
      $location.search({
        query: $scope.query
      });
      return MkmApi.search({
        param1: $scope.query
      }, function(data) {
        var product, _i, _len, _ref, _ref1, _results;
        if ((data != null ? data.product : void 0) == null) {
          return;
        }
        $scope.products = [];
        _ref = [].concat(data.product);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          product = _ref[_i];
          if (((_ref1 = product.category) != null ? _ref1.idCategory : void 0) === "1") {
            _results.push($scope.products.push(DataCache.product(product.idProduct, product)));
          }
        }
        return _results;
      });
    };
    $scope.query = $routeParams.query;
    if ($scope.query) {
      $scope.search();
    }
    return $scope.sort = "name";
  }
]);

mkmobileControllers.controller('ProductCtrl', [
  '$scope', '$routeParams', 'MkmApi', 'DataCache', function($scope, $routeParams, MkmApi, DataCache) {
    $scope.product = DataCache.product($routeParams.productId);
    if ($scope.product == null) {
      MkmApi.product({
        param1: $routeParams.productId
      }, function(data) {
        return $scope.product = DataCache.product($routeParams.productId, data.product);
      });
    }
    $scope.data = MkmApi.articles({
      param1: $routeParams.productId
    });
    return $scope.loadArticles = function() {
      var _ref;
      if (!(((_ref = $scope.data) != null ? _ref.count : void 0) > 100 && $scope.data.article.length < $scope.data.count)) {
        return;
      }
      if ($scope.running != null) {
        return;
      }
      return $scope.running = MkmApi.articles({
        param1: $routeParams.productId,
        param2: $scope.data.article.length + 1
      }, function(data) {
        $scope.running = null;
        return $scope.data.article = $scope.data.article.concat(data.article);
      });
    };
  }
]);

//# sourceMappingURL=controllers.map