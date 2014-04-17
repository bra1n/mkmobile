mkmobileServices.factory 'MkmApiMessage', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  get: ->
    MkmApi.api.messages()

  count: ->
    DataCache.messageCount()
]