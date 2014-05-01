mkmobileServices.factory 'MkmApiMessage', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  get: (id, response) ->
    response = messages: [], count: 0 unless response?
    response.loading = yes
    MkmApi.api.messages {param2: id}, (data) ->
      response.count = data._range or data.message?.length
      response.messages = response.messages.concat data.message if response.count
      response.partner = data.partner
      response.loading = no
    , (err) ->
      response.loading = no
      response.error = err.error
    response

  send: (id, message, cb) ->
    if id and message
      MkmApi.api.messageSend {param2: id, message: message}, (data) ->
        cb?(data.message[0])

  count: ->
    DataCache.messageCount()
]