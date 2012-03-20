# qlocktwo.js: italian locale and logic
#
# Casi: 
#   È L'UNA MENO VENTI; È L'UNA MENO UN QUARTO; È L'UNA MENO DIECI; È L'UNA MENO CINQUE; È L'UNA; È L'UNA E CINQUE; 
#   È L'UNA E DIECI; È L'UNA E UN QUARTO; È L'UNA E VENTI; È L'UNA E VENTICINQUE; È L'UNA E MEZZA; È L'UNA E TRENTACINQUE
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

minutes_index = (minutes) ->
  Math.floor(minutes / 5) # 0..4 -> 0, 5..10 -> 1, ... 55..59 -> 11

hours_index = (hours, minutes) ->
  hours += 1 if minutes_index(minutes) >= 7 # Es. una e trentacinque -> due meno venticinque :-(
  hours % 12 # 0 -> 0, 1 -> 1, ... 11 -> 11, 12 -> 0, 13 -> 1, ... 23 -> 11

pick_hours_tokens = (hours, minutes) ->
  i = hours_index(hours, minutes)
  if i == 1 then [ 'È', hours_tokens[i] ] else [ 'SONO', 'LE', hours_tokens[i] ]


pick_minutes_tokens = (minutes) ->
  i = minutes_index(minutes)

  if 1 <= i <= 6
    [ 'E' ].concat minutes_tokens[i]
  else if i >= 7
    [ 'MENO' ].concat minutes_tokens[i]
  else
    minutes_tokens[i] # -> []

tokens = (hours, minutes) ->
  throw new Error 'hours missing' unless hours?
  throw new Error 'minutes missing' unless minutes?
  pick_hours_tokens(hours, minutes).concat pick_minutes_tokens(minutes)

module.exports = { display: display, tokens: tokens } if module?.exports?