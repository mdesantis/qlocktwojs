observable = require('./observable')

class QLOCKTWO
  constructor: (options = {}) ->
    # REQUIRED
    @display          = options.display        || throw new Error 'display missing'
    @hours_tokens     = options.hours_tokens   || throw new Error 'hours_tokens missing'
    @minutes_tokens   = options.minutes_tokens || throw new Error 'minutes_tokens missing'

    # OPTIONAL
    @date             = options.date ? new Date()
    @display_modifier = options.display_modifier
    @tokens_modifier  = options.tokens_modifier
    @highlight        = options.highlight ? begin: '[', end: ']'

    @change_observable_subject = observable()
    @notify_observers          = @change_observable_subject.notify_observers

  minutes_index: ->
    minutes = @date.getMinutes()
    Math.floor(minutes / 5) # 0..4 -> 0, 5..10 -> 1, ... 55..59 -> 11
  
  hours_index: ->
    hours = @date.getHours()
    hours += 1 if @minutes_index() >= 7 # una e trentacinque -> due meno venticinque :-(
    hours % 12 # 0 -> 0, 1 -> 1, ... 11 -> 11, 12 -> 0, 13 -> 1, ... 23 -> 11
  
  # Casi: 
  pick_hours_tokens: ->
    i = @hours_index()
    if i == 1 then [ 'È', @hours_tokens[i] ] else [ 'SONO', 'LE', @hours_tokens[i] ]

  # Casi: 
  #   è l'una meno venti; è l'una meno un quarto; è l'una meno dieci; è l'una meno cinque; è l'una; è l'una e cinque; 
  #   è l'una e dieci; è l'una e un quarto; è l'una e venti; è l'una e venticinque; è l'una e mezza; è l'una e trentacinque
  pick_minutes_tokens: ->
    i = @minutes_index()

    if 0 < i <= 6
      [ 'E' ].concat @minutes_tokens[i]
    else if i > 6
      [ 'MENO' ].concat @minutes_tokens[i]
    else
      @minutes_tokens[i]
  
  tokens: ->
    @pick_hours_tokens().concat @pick_minutes_tokens()
  
  update_display: () ->
    display = @display
    display = @display_modifier(display) if @display_modifier

    tokens = @tokens()
    tokens = @tokens_modifier(tokens) if @tokens_modifier
    
    offset = 0
    
    for token in tokens
      i = display.indexOf(token, offset)
      throw new Error "token '#{token}' not found" if i == -1
      
      # ex. token = 'OTTO'; ...TREOTTONOVE... -> ...TRE[OTTO]NOVE...
      display = 
        display.substring(0, i)           + # ...TRE
        @highlight['begin']               + # [
        token                             + # OTTO
        @highlight['end']                 + # ]
        display.substring(i+token.length)   # NOVE...
      
      offset = i + @highlight['begin'].length + token.length + @highlight['end'].length
      
    display
      
    
d = new Date()
# So che non è una matrice, ma rende bene l'idea :P
display = """
          SONORLEBORE
          ÈRĽUNASDUEZ
          TREOTTONOVE
          DIECIUNDICI
          DODICISETTE
          QUATTROCSEI
          CINQUESMENO
          ECUNOQUARTO
          VENTICINQUE
          DIECIEMEZZA
          """
hours_tokens = [ 
  "DODICI", "ĽUNA",     "DUE",
  "TRE",    "QUATTRO", "CINQUE",
  "SEI",    "SETTE",   "OTTO",
  "NOVE",   "DIECI",   "UNDICI" 
]
minutes_tokens = [ 
  [],               ['CINQUE'],      ['DIECI'], 
  ['UN', 'QUARTO'], ['VENTI'],       ['VENTICINQUE'], 
  ['MEZZA'],        ['VENTICINQUE'], ['VENTI'], 
  ['UN', 'QUARTO'], ['DIECI'],       ['CINQUE']
]

#display = display.split('\n').map( (v) -> v.split('').join(' ') ).join('\n')
#hours_tokens = hours_tokens.map( (v) -> v.split('').join(' ') )
#minutes_tokens = minutes_tokens.map( (v) -> v.map( (_v) -> _v.split('').join(' ')) )

#console.log display
#console.log hours_tokens
#console.log minutes_tokens

display_modifier_func = (display) -> display.split('\n').map( (v) -> v.split('').join(' ') ).join('\n')
tokens_modifier_func = (tokens) -> tokens.map( (v) -> v.split('').join(' ') )

options = 
  display:        display
  hours_tokens:   hours_tokens
  minutes_tokens: minutes_tokens
  highlight:
    begin: '\033[47;30m'
    end:   '\033[0m'
  display_modifier: display_modifier_func
  tokens_modifier:  tokens_modifier_func

clock = new QLOCKTWO(options)
console.log "#{clock.date.getHours()}:#{clock.date.getMinutes()}"
console.log clock.update_display()
console.log ''

# add support for server side
#module.exports = QLOCKTWO if module?.exports?
#module.exports = { model: Model, controller: Controller, view: View } if module?.exports?