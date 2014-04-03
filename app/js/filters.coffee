angular.module 'mkmobileFilters', []
.filter 'expansionIcon', ->
  # return expansion
  (expansion) ->
    expansion? and expansion.toLowerCase().replace(/[^a-z0-9]/gi,'').replace(/^wcd\d+.*$/,'worldchampionshipdecks') or 'error'
.filter 'productImage', ->
  # return productImage
  (image) ->
    image? and '//tcgimages.eu/' + image.substr(2) or '/img/card.jpg'
