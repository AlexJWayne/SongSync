// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.SongSync = (function() {
    SongSync.prototype.eventTypes = ['segments', 'beats', 'bars', 'tatums', 'sections'];

    SongSync.prototype.eventTypesSingular = {
      sections: 'section',
      tatums: 'tatum',
      bars: 'bar',
      beats: 'beat',
      segments: 'segment'
    };

    function SongSync(audioPath, dataPath) {
      var type, _i, _len, _ref;
      this.audioPath = audioPath;
      this.dataPath = dataPath;
      this.start = __bind(this.start, this);
      this.scheduleEvents = __bind(this.scheduleEvents, this);
      smokesignals.convert(this);
      this.loaded = false;
      this.createAudioElement();
      this.fetchSongData();
      this.eventPlayHeads = {};
      _ref = this.eventTypes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        type = _ref[_i];
        this.eventPlayHeads[type] = 0;
      }
    }

    SongSync.prototype.fetchSongData = function() {
      return reqwest({
        url: this.dataPath,
        type: 'json',
        success: (function(_this) {
          return function(resp) {
            _this.data = resp;
            _this.loaded = true;
            return _this.emit('load');
          };
        })(this)
      });
    };

    SongSync.prototype.createAudioElement = function() {
      var audio;
      return this.audio || (this.audio = (audio = document.createElement('audio'), audio.src = this.audioPath, audio.controls = 'controls', audio.addEventListener('timeupdate', this.scheduleEvents, false), audio));
    };

    SongSync.prototype.scheduleEvents = function() {
      var event, i, now, type, _i, _j, _len, _ref, _ref1, _ref2;
      now = this.audio.currentTime;
      _ref = this.eventTypes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        type = _ref[_i];
        for (i = _j = _ref1 = this.eventPlayHeads[type], _ref2 = this.data[type].length; _ref1 <= _ref2 ? _j < _ref2 : _j > _ref2; i = _ref1 <= _ref2 ? ++_j : --_j) {
          event = this.data[type][i];
          if (event.start < now + .350) {
            this.eventPlayHeads[type] = i;
            this.scheduleEvent(type, event);
          } else {
            this.eventPlayHeads[type] = i;
            break;
          }
        }
      }
    };

    SongSync.prototype.scheduleEvent = function(type, event) {
      var delay;
      delay = (event.start - this.audio.currentTime) * 1000;
      return setTimeout((function(_this) {
        return function() {
          return _this.emit(_this.eventTypesSingular[type], event);
        };
      })(this), delay);
    };

    SongSync.prototype.start = function() {
      return this.audio.play();
    };

    return SongSync;

  })();

}).call(this);