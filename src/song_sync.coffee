class window.SongSync
  eventTypes: [
    'segments'
    'beats'
    'bars'
    'tatums'
    'sections'
  ]

  eventTypesSingular: {
    sections: 'section'
    tatums: 'tatum'
    bars: 'bar'
    beats: 'beat'
    segments: 'segment'
  }

  constructor: (@audioPath, @dataPath) ->

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
      audio.addEventListener 'timeupdate', @scheduleEvents, no
      audio
    )

  scheduleEvents: =>
    now = @audio.currentTime

    for type in @eventTypes
      for i in [ @eventPlayHeads[type]...@data[type].length ]
        event = @data[type][i]

        if event.start < now + .350
          @eventPlayHeads[type] = i
          @scheduleEvent type, event

        else
          @eventPlayHeads[type] = i
          break

    return

  scheduleEvent: (type, event) ->
    delay = (event.start - @audio.currentTime) * 1000

    setTimeout =>
      @emit @eventTypesSingular[type], event
    , delay

  start: =>
    @audio.play()
