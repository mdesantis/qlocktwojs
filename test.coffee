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

d = new Date

options = 
  date:   d
  locale: require('./locales/it')

clock = new QLOCKTWO(options)

for hours in [0..11]
  clock.date.setHours hours
  for minutes in [0..59] by 5
    clock.date.setMinutes minutes
    console.log clock.render()
