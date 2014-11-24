class window.SongSync
  eventTypes: [
    'segments'
    'beats'
    'bars'
    'tatums'
    'sections'
  ]

  eventTypesSingular:
    sections: 'section'
    tatums:   'tatum'
    bars:     'bar'
    beats:    'beat'
    segments: 'segment'

  schedulingBuffer: .35 # seconds

  constructor: (@audioPath, @dataPath) ->
    @dataPath ||= @audioPath.replace /\.[\w\d]+?$/, '.json'

    smokesignals.convert this
    @loaded = no

    @createAudioElement()
    @fetchSongData()

    @eventPlayHeads = {}
    for type in @eventTypes
      @eventPlayHeads[type] = 0

  fetchSongData: ->
    reqwest
      url: @dataPath
      type: 'json'

      success: (resp) =>
        @data = resp
        @loaded = yes
        @emit 'load'

  createAudioElement: ->
    @audio ||= (
      audio = document.createElement 'audio'
      audio.src = @audioPath
      audio.controls = 'controls'
      audio.addEventListener 'timeupdate', @scheduleEvents, false
      audio
    )

  scheduleEvents: =>
    now = @audio.currentTime

    for type in @eventTypes
      for i in [ @eventPlayHeads[type]...@data[type].length ]
        event = @data[type][i]
        @eventPlayHeads[type] = i

        if event.start < now + @schedulingBuffer
          @scheduleEvent @eventTypesSingular[type], event
        else
          break

    return

  scheduleEvent: (type, event) ->
    delay = (event.start - @audio.currentTime) * 1000

    setTimeout =>
      @emit type, event
    , delay

  start: =>
    @audio.play()
