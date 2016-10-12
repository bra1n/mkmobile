# header with search functionality
angular.module 'mkmobile.directives.header', []
.directive 'mkmHeader', (MkmApiAuth, MkmApiMarket, MkmApiCart, $state, $transitions) ->
  restrict: 'E'
  templateUrl: '/partials/directives/header.html'
  link: (scope) ->
    try scope.query = sessionStorage.getItem('search') or ''
    scope.sort = 'enName'
    scope.gameId = window.gameId or 1
    scope.languages = MkmApiAuth.getLanguages()
    MkmApiAuth.getAccount (data) ->
      scope.idLanguage = MkmApiAuth.getLanguage()
      scope.cart = MkmApiCart.count()
      scope.isActivated = data.account?.isActivated

    # change language
    scope.updateLanguage = -> MkmApiAuth.setLanguage scope.idLanguage
    # log the user out
    scope.logout = ->
      scope.menuOpen = no
      MkmApiAuth.logout()
    # toggle search
    scope.toggleSearch = ->
      if scope.searchOpen
        scope.searchOpen = no unless scope.query or $state.is 'login'
        scope.query = ''
      else
        scope.searchOpen = yes
        scope.menuOpen = no
    # toggle menu
    scope.toggleMenu = ->
      if scope.menuOpen
        scope.menuOpen = no
      else
        scope.menuOpen = yes
        scope.searchOpen = no unless $state.is 'login'

    # infinite scrolling
    scope.loadResults = ->
      # don't load more if we already show all of them
      return if scope.results.products.length >= scope.results.count or scope.results.loading
      MkmApiMarket.search scope.query, scope.results

    # searching
    scope.$watch 'query', (query) ->
      try sessionStorage.setItem 'search', query
      scope.results = MkmApiMarket.search query
    # listen to route changes
    $transitions.onSuccess {}, (trans) ->
      scope.searchOpen = scope.menuOpen = no
      if trans.to().name is 'login'
        scope.searchOpen = yes
        scope.query = ''
    # listen to language changes
    scope.$root.$on '$translateChangeSuccess', ->
      scope.idLanguage = MkmApiAuth.getLanguage()
    # listen to cart changes
    scope.$root.$on '$cartChange', (event, amount) ->
      scope.cart = amount
    # listen to auth changes
    scope.$root.$on '$authChange', (event, account) ->
      scope.isActivated = !!account.isActivated
