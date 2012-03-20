# observable = require('./observable')

class QLOCKTWO
  constructor: (options = {}) ->

    if options.locale
      @display = options.locale.display
      @tokens  = options.locale.tokens
    else
      @display = options.display
      @tokens  = options.tokens

    # REQUIRED
    throw new Error 'display argument missing'  unless @display
    throw new Error 'tokens() argument missing' unless @tokens

    @date             = options.date ? new Date()
    @display_modifier = options.display_modifier
    @tokens_modifier  = options.tokens_modifier
    @highlight        = options.highlight ? begin: '[', end: ']'

    # @change_observable_subject = observable()
    # @notify_observers          = @change_observable_subject.notify_observers
  
  render: () ->
    display = @display
    display = @display_modifier(display) if @display_modifier

    tokens = @tokens( @date.getHours(), @date.getMinutes() )
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

module.exports = QLOCKTWO if module?.exports?
