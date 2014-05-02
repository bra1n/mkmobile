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
      console.log "got cache", response
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
      DataCache.order orderId, data.order
      cb?()
    false

  evaluate: (orderId, evaluation, cb) ->
    evaluation.orderId = orderId
    MkmApi.api.orderEvaluate evaluation, (data) ->
      DataCache.order orderId, data # todo update to data.order
      cb?()
    false

  getEvaluation: ->
    evaluationGrade: 1
    itemDescription: 1
    packaging: 1
    speed: 1
    complaint: []
    comment: ""

  getComplaints: -> [
    {value: "badCommunication",   label:"Bad communication"}
    {value: "incompleteShipment", label:"Items were missing"}
    {value: "notFoil",            label:"Ordered Foil - Got Non Foil"}
    {value: "rudeSeller",         label:"Rude seller"}
    {value: "shipDamage",         label:"Damaged during shipping"}
    {value: "unorderedShipment",  label:"Contents was unordered"}
    {value: "wrongEd",            label:"Wrong version"}
    {value: "wrongLang",          label:"Wrong language"}
  ]

  getEvaluations: -> [
    {label: "Very good", value: 1}
    {label: "Good",      value: 2}
    {label: "Neutral",   value: 3}
    {label: "Bad",       value: 4}
  ]
]