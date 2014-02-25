// Generated by CoffeeScript 1.7.1
var mkmobileDirectives;

mkmobileDirectives = angular.module('mkmobileDirectives', []);

mkmobileDirectives.directive('infiniteScroll', function() {
  return {
    link: function(scope, elm, attr) {
      var docElem, scrollHandler;
      docElem = document.documentElement;
      scrollHandler = function() {
        if (docElem.scrollTop + docElem.clientHeight - elm[0].offsetTop >= elm[0].scrollHeight) {
          return scope.$apply(attr.infiniteScroll);
        }
      };
      $(window).bind('scroll', scrollHandler);
      return scope.$on('$destroy', function() {
        return $(window).unbind('scroll', scrollHandler);
      });
    }
  };
});

//# sourceMappingURL=directives.map