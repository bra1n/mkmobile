# header with search functionality
angular.module 'mkmobile.directives.header', []
.directive 'mkmHeader', [
  'MkmApiAuth', 'MkmApiMarket'
  (MkmApiAuth, MkmApiMarket) ->
    restrict: 'E'
    templateUrl: '/partials/directives/header.html'
    link: (scope) ->
      scope.query = sessionStorage.getItem("search") or ""
      scope.sort = "enName"
      scope.gameId = window.gameId or 1
      scope.languages = MkmApiAuth.getLanguages()
      scope.idLanguage = MkmApiAuth.getLanguage()

      # change language
      scope.updateLanguage = -> MkmApiAuth.setLanguage scope.idLanguage
      # log the user out
      scope.logout = ->
        scope.menuOpen = no
        MkmApiAuth.logout()
      # toggle search
      scope.toggleSearch = ->
        if scope.searchOpen
          scope.searchOpen = no unless scope.query
          scope.query = ""
        else
          scope.searchOpen = yes
          scope.menuOpen = no
      # toggle menu
      scope.toggleMenu = ->
        if scope.menuOpen
          scope.menuOpen = no
        else
          scope.menuOpen = yes
          scope.searchOpen = no

      # infinite scrolling
      scope.loadResults = ->
        # don't load more if we already show all of them
        return if scope.results.products.length >= scope.results.count or scope.results.loading
        MkmApiMarket.search scope.query, scope.results

      # searching
      scope.$watch 'query', (query) ->
        sessionStorage.setItem "search", query
        scope.results = MkmApiMarket.search query
      # listen to route changes
      scope.$root.$on '$routeChangeStart', ->
        scope.menuOpen = scope.searchOpen = no
      # listen to language changes
      scope.$root.$on '$translateChangeSuccess', ->
        scope.idLanguage = MkmApiAuth.getLanguage()
]