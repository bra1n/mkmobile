angular.module 'mkmobileFilters', []
# calculate expansion icon position
.filter 'expansionIcon', -> (index) -> {backgroundPosition: (index % 10)*-21+"px "+Math.floor(index/10)*-21+"px" }
# generate rarity icon class name
.filter 'rarityIcon', -> (product) -> 'icon rarity rarity-'+(product.idGame or '1')+'-'+(product.rarity or 'none').replace(RegExp(' ','g'),'').toLowerCase() if product?
# get product image url
.filter 'productImage', -> (image) -> image? and '//www.mkmapi.eu/' + image.substr(2) or '/img/card.jpg'
# return label for needle value in haystack object
.filter 'findInMap', -> (needle, haystack) -> return obj.label for obj in haystack when obj.value is needle
# return array with range of 1 to input elements
.filter 'range', -> (input) -> [1..input]
.filter 'truncate', -> (text, length, end) ->
  length or= 100
  end or= "..."
  return text if text.length <= length or text.length - end.length <= length
  String(text).substring(0, length-end.length) + end