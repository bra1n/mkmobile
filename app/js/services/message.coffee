mkmobileServices.factory 'MkmApiMessage', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  get: (id, response) ->
    response = messages: [], count: 0 unless response?
    response.loading = yes
    MkmApi.api.messages {param2: id}, (data) ->
      response.count = data._range or data.message?.length
      response.messages = response.messages.concat data.message if response.count
      response.partner = response.messages[0].partner if id? # todo replace with general user for single message thread
      response.loading = no
    response

  count: ->
    DataCache.messageCount()
]