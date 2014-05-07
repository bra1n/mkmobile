angular.module 'mkmobileFilters', []
# calculate expansion icon position
.filter 'expansionIcon', -> (index) -> {backgroundPosition: (index % 10)*-21+"px "+Math.floor(index/10)*-21+"px" }
# get product image url
.filter 'productImage', -> (image) -> image? and '//www.mkmapi.eu/' + image.substr(2) or '/img/card.jpg'
# return label for needle value in haystack object
.filter 'findInMap', -> (needle, haystack) -> return obj.label for obj in haystack when obj.value is needle
# return array with range of 1 to input elements
.filter 'range', -> (input) -> [1..input]
