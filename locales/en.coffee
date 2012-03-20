# qlocktwo.js: english locale and logic
display = """
          ITLISASTIME
          ACQUARTERDC
          TWENTYFIVEX
          HALFBTENFTO
          PASTERUNINE
          ONESIXTHREE
          FOURFIVETWO
          EIGHTELEVEN
          SEVENTWELVE
          TENSEƠCLOCK
        """
hours_tokens = [
  "TWELVE", "ONE",   "TWO",
  "THREE",  "FOUR",  "FIVE",
  "SIX",    "SEVEN", "EIGHT",
  "NINE",   "TEN",   "ELEVEN" 
]
minutes_tokens = [
  [],               ['FIVE'],       ['TEN'], 
  ['A', 'QUARTER'], ['TWENTY'],     ['TWENTYFIVE'], 
  ['HALF'],         ['TWENTYFIVE'], ['TWENTY'], 
  ['A', 'QUARTER'], ['TEN'],        ['FIVE']
]

minutes_index = (minutes) ->
  Math.floor(minutes / 5) # 0..4 -> 0, 5..10 -> 1, ... 55..59 -> 11

hours_index = (hours, minutes) ->
  hours += 1 if minutes_index(minutes) >= 7 # Ex. thirtyfive past one -> twentyfive to two
  hours % 12 # 0 -> 0, 1 -> 1, ... 11 -> 11, 12 -> 0, 13 -> 1, ... 23 -> 11

pick_hours_tokens = (hours, minutes) ->
  i = hours_index(hours, minutes)
  if i == 1 then [ hours_tokens[i], 'ƠCLOCK' ] else [ hours_tokens[i] ]

# Cases: 
#   IT IS TWENTYFIVE TO THREE; IT IS TWENTY TO THREE; IT IS A QUARTER TO THREE; IT IS TEN TO THREE; IT IS FIVE TO THREE; 
#   IT IS THREE ƠCLOCK; IT IS FIVE PAST THREE; IT IS TEN PAST THREE; IT IS A QUARTER PAST THREE; IT IS TWENTY PAST THREE; 
#   IT IS TWENTYFIVE PAST THREE; IT IS HALF PAST THREE
pick_minutes_tokens = (minutes) ->
  i = minutes_index(minutes)

  if 1 <= i <= 6
    minutes_tokens[i].concat [ 'PAST' ]
  else if i >= 7
    minutes_tokens[i].concat [ 'TO' ]
  else
    minutes_tokens[i] # -> []

tokens = (hours, minutes) ->
  throw new Error 'hours missing' unless hours?
  throw new Error 'minutes missing' unless minutes?
  ['IT', 'IS'].concat pick_minutes_tokens(minutes).concat pick_hours_tokens(hours, minutes)

module.exports = display: display, tokens: tokens if module?.exports?