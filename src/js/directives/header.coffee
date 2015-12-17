# header with search functionality
angular.module 'mkmobile.directives.header', []
.directive 'mkmHeader', [
  'MkmApiAuth', 'MkmApiMarket'
  (MkmApiAuth, MkmApiMarket) ->
    restrict: 'E'
    templateUrl: '/partials/directives/header.html'
    link: (scope) ->
      scope.languages = MkmApiAuth.getLanguages()
      scope.idLanguage = MkmApiAuth.getLanguage()
      scope.updateLanguage = -> MkmApiAuth.setLanguage scope.idLanguage
      scope.logout = -> MkmApiAuth.logout()
      # listen to language changes
      scope.$root.$on '$translateChangeSuccess', ->
        scope.idLanguage = MkmApiAuth.getLanguage()
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

      # init scope vars
      scope.query = sessionStorage.getItem("search") or ""
      scope.sort = "enName"
      scope.gameId = window.gameId or 1

      # searching
      scope.$watch 'query', (query, oldQuery) ->
        sessionStorage.setItem "search", query
        scope.results = MkmApiMarket.search query
]