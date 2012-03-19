# A generic observable subject class that is useful in model creation.
#
observable = () ->

  observers = []
  
  add_observer = (o) ->
    throw 'observer must be a function' if typeof o != 'function'

    for observer in observers
      throw 'observer already in the list' if observer == o

    observers.push o

  remove_observer = (o) ->
    for observer, i in observers
       return observers.splice i, 1 if observer == o

  notify_observers = (data) ->
    # Make a copy of observer list in case the list is mutated during the notifications.
    observers_snapshot = observers.slice 0
    observer(data) for observer in observers_snapshot

    # Saves coffeescript from collecting observer(data) return values for the return
    return

  return {
    add_observer:     add_observer
    remove_observer:  remove_observer
    notify_observers: notify_observers
  }

module.exports = observable if module?.exports?