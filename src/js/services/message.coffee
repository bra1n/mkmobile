angular.module 'mkmobile.services.message', []
.factory 'MkmApiMessage', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  get: (id, cb) ->
    response = messages: [], count: 0, loading: yes
    MkmApi.api.messages {param2: id}, (data) ->
      if id?
        # flag unread messages as read, now that you're looking at them, and prepare date headlines
        unreadCount = DataCache.messageCount()
        for message in data.message
          unreadCount-- if message.unread
          message.date = new Date message.date
        DataCache.messageCount unreadCount
        response.count = data._range or data.message?.length
        response.messages = response.messages.concat data.message if response.count
        response.partner = data.partner
        cb?()
      else
        response.count = data._range or data.thread?.length
        response.messages = response.messages.concat data.thread if response.count
        # recalculate unread message count
        # fixme: this will not consider the (unlikely) situation where you have 100+ unread threads
        unreadCount = 0
        unreadCount += thread.unreadMessages for thread in response.messages
        DataCache.messageCount unreadCount
        cb?()
      response.loading = no
    , (err) ->
      response.loading = no
      response.error = err.error
    response

  send: (id, message, response) ->
    response = messages: [], count: 0 unless response?
    if id and message
      response.loading = yes
      MkmApi.api.messageSend {param2: id, message: message}, (data) ->
        response.loading = no
        response.count = data._range or data.message?.length
        response.messages = data.message
        response.partner = data.partner
        message.date = new Date message.date for message in response.messages
      , (err) ->
        response.loading = no
        response.error = err.error

  delete: (threadId, messageId) -> MkmApi.api.messageDelete {param2: threadId, param3: messageId}

  # unread message count
  count: ->
    DataCache.messageCount()
]
