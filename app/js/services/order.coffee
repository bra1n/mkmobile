mkmobileServices.factory 'MkmApiOrder', [ 'MkmApi', 'DataCache', (MkmApi, DataCache) ->
  actorMap =
    sells:      1
    buys:       2
  statusMap =
    bought:     1
    paid:       2
    sent:       4
    received:   8
    lost:       32
    cancelled:  128
  get: ({mode, status, orderId, response}) ->
    if orderId?
      response = order: DataCache.order orderId
      unless response.order?
        response.loading = yes
        MkmApi.api.order {param1: orderId}, (data) =>
          response.loading = no
          response.order = DataCache.order orderId, data.order
        , (error) ->
          response.error = error
          response.loading = no
    else
      response = count: 0, orders: [] unless response?
      query =
        param2: actorMap[mode] or 1
        param3: statusMap[status] or 1
        param4: response.orders.length + 1
      response.loading = yes
      MkmApi.api.orders query, (data) =>
        response.count = data._range or data.order?.length
        response.orders = response.orders.concat data.order.map((val) => DataCache.order val.idOrder, val) if response.count
        response.loading = no
      , (error) ->
        response.error = error
        response.loading = no
    response
  update: ({orderId, status, reason}, cb) ->
    request = action: status
    request.reason = reason if reason?
    MkmApi.api.orderUpdate {param1: orderId}, request, (data) ->
      console.log data
      DataCache.order orderId, data.order
      cb?()
    false
]