QLOCKTWO = require('./qlocktwo')

# display_modifier_func = (display) -> display.split('\n').map( (v) -> v.split('').join(' ') ).join('\n')
# tokens_modifier_func = (tokens) -> tokens.map( (v) -> v.split('').join(' ') )

# options = 
#   highlight:
#     begin: '\033[47;30m'
#     end:   '\033[0m'
#   display_modifier: display_modifier_func
#   tokens_modifier:  tokens_modifier_func
#   locale:           require('./locales/en')

# clock = new QLOCKTWO(options)
# console.log "#{clock.date.getHours()}:#{clock.date.getMinutes()}"
# console.log clock.render()
# console.log ''


# d = new Date

# options = 
#   date:   d
#   locale: require('./locales/it')

# clock = new QLOCKTWO(options)

# console.log clock.render()

# clock.on 'date_changed', (date) ->
#   console.log "date changed! Actual date is: #{date}"


# clock.set_time 'ciao'

# for hours in [0..11]
#   clock.date.setHours hours
#   for minutes in [0..59] by 5
#     clock.date.setMinutes minutes
#     console.log clock.render()


# process.stdout.write "foo\rbar"
# process.stdout.write "\rasdd"
# process.stdout.write "\rgtotmop"
# process.stdout.write "\rvo"

while true
  setTimeout( () ->
    console.log 'ciao',
  1000)

# for i in [0..10]
#   console.log "\u000D%s: %d", "One moment please", i