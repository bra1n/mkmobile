angular.module 'mkmobileFilters', []
.filter 'expansionIcon', ->
  # return expansion
  (expansion) -> expansion? and expansion.toLowerCase().replace(/[^a-z0-9]/gi,'') or 'error'