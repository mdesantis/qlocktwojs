(function() {
  var QLOCKTWO, clock, d, display, display_modifier_func, hours_tokens, minutes_tokens, observable, options, token_modifier_func;

  observable = require('./observable');

  QLOCKTWO = (function() {

    function QLOCKTWO(options) {
      var _ref, _ref2;
      if (options == null) options = {};
      this.date = (_ref = options.date) != null ? _ref : new Date();
      this.display = options.display;
      this.hours_tokens = options.hours_tokens;
      this.minutes_tokens = options.minutes_tokens;
      this.display_modifier = options.display_modifier;
      this.token_modifier = options.token_modifier;
      this.highlight = (_ref2 = options.highlight) != null ? _ref2 : {
        begin: '[',
        end: ']'
      };
      this.change_observable_subject = observable();
      this.notify_observers = this.change_observable_subject.notify_observers;
    }

    QLOCKTWO.prototype.minutes_index = function() {
      var minutes;
      minutes = this.date.getMinutes();
      return Math.floor(minutes / 5);
    };

    QLOCKTWO.prototype.hours_index = function() {
      var hours;
      hours = this.date.getHours();
      if (this.minutes_index() >= 7) hours += 1;
      return hours % 12;
    };

    QLOCKTWO.prototype.pick_hours_tokens = function() {
      var i;
      i = this.hours_index();
      if (i === 1) {
        return ['È', this.hours_tokens[i]];
      } else {
        return ['SONO', 'LE', this.hours_tokens[i]];
      }
    };

    QLOCKTWO.prototype.pick_minutes_tokens = function() {
      var i;
      i = this.minutes_index();
      if ((0 < i && i <= 6)) {
        return ['E'].concat(this.minutes_tokens[i]);
      } else if (i > 6) {
        return ['MENO'].concat(this.minutes_tokens[i]);
      } else {
        return this.minutes_tokens[i];
      }
    };

    QLOCKTWO.prototype.tokens = function() {
      return this.pick_hours_tokens().concat(this.pick_minutes_tokens());
    };

    QLOCKTWO.prototype.highlight_tokens = function() {
      var display, i, offset, token, _i, _len, _ref;
      display = this.display;
      offset = 0;
      _ref = this.tokens();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        token = _ref[_i];
        i = display.indexOf(token, offset);
        if (i === -1) throw "token '" + token + "' not found";
        display = display.substring(0, i) + this.highlight['begin'] + token + this.highlight['end'] + display.substring(i + token.length);
        offset = i + this.highlight['begin'].length + token.length + this.highlight['end'].length;
      }
      return display;
    };

    return QLOCKTWO;

  })();

  d = new Date();

  display = "SONORLEBORE\nÈRĽUNASDUEZ\nTREOTTONOVE\nDIECIUNDICI\nDODICISETTE\nQUATTROCSEI\nCINQUESMENO\nECUNOQUARTO\nVENTICINQUE\nDIECIEMEZZA";

  hours_tokens = ["DODICI", "ĽUNA", "DUE", "TRE", "QUATTRO", "CINQUE", "SEI", "SETTE", "OTTO", "NOVE", "DIECI", "UNDICI"];

  minutes_tokens = [[], ['CINQUE'], ['DIECI'], ['UN', 'QUARTO'], ['VENTI'], ['VENTICINQUE'], ['MEZZA'], ['VENTICINQUE'], ['VENTI'], ['UN', 'QUARTO'], ['DIECI'], ['CINQUE']];

  display_modifier_func = function(display) {
    return display.split('\n').map(function(v) {
      return v.split('').join(' ');
    }).join('\n');
  };

  token_modifier_func = function(token) {
    return token.split('').join(' ');
  };

  options = {
    display: display,
    hours_tokens: hours_tokens,
    minutes_tokens: minutes_tokens,
    highlight: {
      begin: '\033[47;30m',
      end: '\033[0m'
    },
    display_modifier: display_modifier_func,
    token_modifier: token_modifier_func
  };

  clock = new QLOCKTWO(options);

  console.log("" + (clock.date.getHours()) + ":" + (clock.date.getMinutes()));

  console.log(clock.highlight_tokens());

  console.log('');

}).call(this);
