// Generated by CoffeeScript 1.7.1
angular.module('mkmobileFilters', []).filter('expansionIcon', function() {
  return function(expansion) {
    return (expansion != null) && expansion.toLowerCase().replace(/[^a-z0-9]/gi, '').replace(/^wcd\d+.*$/, 'worldchampionshipdecks') || 'error';
  };
});

//# sourceMappingURL=filters.map
