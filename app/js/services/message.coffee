mkmobileServices.factory 'MkmApiMessage', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  get: (id) ->
    MkmApi.api.messages()

  count: ->
    DataCache.messageCount()
]