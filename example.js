// Some pure functions that are handy to have around.
// These could be created in more limited visibility scopes.

var isValidHour = function(h) {
    return (typeof h === 'number') &&
           (Math.floor(h) == h) &&
           (h >= 0) &&
           (h <= 23);
};

var isValidMinute = function(m) {
    return (typeof m === 'number') &&
           (Math.floor(m) == m) &&
           (m >= 0) &&
           (m <= 59);
};

var isValidSecond = isValidMinute;

var padNum = function(i) {
    return ((i < 10) ? '0' : '') + i;
};

var formatTimeString = function(h, m, s) {
    return padNum(h) + ':' + padNum(m) + ':' + padNum(s);
};


// A generic observable subject class that is useful in model creation.
//
var makeObservableSubject = function() {    
    var observers = [];
    
    var addObserver = function(o) {
        if (typeof o !== 'function') {
            throw new Error('observer must be a function');
        }
        for (var i=0, ilen=observers.length; i<ilen; i++) {
            var observer = observers[i];
            if (observer === o) {
                throw new Error('observer already in the list');
            }
        }
        observers.push(o);
    };
    
    var removeObserver = function(o) {
        for (var i=0, ilen=observers.length; i<ilen; i++) {
            var observer = observers[i];
            if (observer === o) {
                observers.splice(i, 1);
                return;
            }
        }
        throw new Error('could not find observer in list of observers');
    };
    
    var notifyObservers = function(data) {
        // Make a copy of observer list in case the list
        // is mutated during the notifications.
        var observersSnapshot = observers.slice(0);
        for (var i=0, ilen=observersSnapshot.length; i<ilen; i++) {
            observersSnapshot[i](data);
        }
    };
    
    return {
        addObserver: addObserver,
        removeObserver: removeObserver,
        notifyObservers: notifyObservers
    };
};


// The clock model that widgets can observe an controllers can mutate.
// We are pretending there is no built in Date class.
//
var makeClockModel = function() {

    var hour = 0;
    var minute = 0;
    var second = 0;
    var running = false;
    var interval = null;
    var changeObservableSubject = makeObservableSubject();
    var notifyObservers = changeObservableSubject.notifyObservers;
    
    var getTime = function() {
        return {hour:hour, minute:minute, second:second};
    };
    
    var setTime = function(h, m, s) {
        // Always use very robust checking on values sent to a model.
        if (!isValidHour(h)) {
            throw new Error('hour is not valid');
        }
        if (!isValidMinute(m)) {
            throw new Error('minute is not valid');
        }
        if (!isValidSecond(s)) {
            throw new Error('second is not valid');
        }
        hour = h;
        minute = m;
        second = s;
        notifyObservers();
    };
    
    var resetTime = function() {
        setTime(0, 0, 0);
    };
    
    var tick = function() {
        var h = hour;
        var m = minute;
        var s = second;
        
        s++;
        if (s > 59) {
            s = 0;
            m++;
            if (m > 59) {
                m = 0;
                h++;
                if (h > 23) {
                    h = 0;
                }
            }
        }
        
        setTime(h, m, s);
    };
    
    var start = function() {
        if (!running) {
            running = true;
            interval = setInterval(tick, 1000);
            notifyObservers();
        }
    };
    
    var stop = function() {
        if (running) {
            running = false;
            clearInterval(interval);
            interval = null;
            notifyObservers();
        }
    };
    
    // Note the mixin technology at work for exposing the observer
    // functions as part of the clock model API.
    return {
        getTime: getTime,
        setTime: setTime,
        resetTime: resetTime,
        start: start,
        stop: stop,
        addChangeObserver: changeObservableSubject.addObserver,
        removeChangeObserver: changeObservableSubject.removeObserver
    };
};


// A simple view-only widget that shows a clock model's time.
//
var makeDigitalClockWidget = function(initialClockModel) {

    var clockModel;
    var rootEl = document.createElement('div');
    
    var showTime = function(time) {
        rootEl.innerHTML = formatTimeString(time.hour, time.minute, time.second);
    };

    var clockChangeObserver = function() {
        showTime(clockModel.getTime());
    };

    var setClockModel = function(cm) {
        if (!cm) {
            throw new Error('must supply a clock model');
        }
        if (clockModel) {
            clockModel.removeChangeObserver(clockChangeObserver);
        }
        clockModel = cm;
        clockModel.addChangeObserver(clockChangeObserver);
        showTime(clockModel.getTime());
    };

    setClockModel(initialClockModel);

    return {
        getRootEl: function() {
            return rootEl;
        },
        setClockModel: setClockModel
    };
};


// A more complex view-only widet that shows a clock model's time.
// The showTime code is from 
//     https://developer.mozilla.org/en/Canvas_tutorial/Basic_animations
//
var makeAnalogClockWidget = function(initialClockModel) {

    var clockModel;
    var rootEl = document.createElement('canvas');
    rootEl.width = '150';
    rootEl.height = '150';
    var ctx = rootEl.getContext('2d');
    
    var showTime = function(time) {
        ctx.save();
        ctx.clearRect(0,0,150,150);
        ctx.translate(75,75);
        ctx.scale(0.4,0.4);
        ctx.rotate(-Math.PI/2);
        ctx.strokeStyle = "black";
        ctx.fillStyle = "white";
        ctx.lineWidth = 8;
        ctx.lineCap = "round";

        // hour marks
        ctx.save();
        for (var i=0;i<12;i++){
          ctx.beginPath();
          ctx.rotate(Math.PI/6);
          ctx.moveTo(100,0);
          ctx.lineTo(120,0);
          ctx.stroke();
        }
        ctx.restore();

        // minute marks
        ctx.save();
        ctx.lineWidth = 5;
        for (i=0;i<60;i++){
          if (i%5!=0) {
            ctx.beginPath();
            ctx.moveTo(117,0);
            ctx.lineTo(120,0);
            ctx.stroke();
          }
          ctx.rotate(Math.PI/30);
        }
        ctx.restore();

        var sec = time.second;
        var min = time.minute;
        var hr  = time.hour;
        hr = hr>=12 ? hr-12 : hr;

        ctx.fillStyle = "black";

        // write hours
        ctx.save();
        ctx.rotate( hr*(Math.PI/6) + (Math.PI/360)*min + (Math.PI/21600)*sec )
        ctx.lineWidth = 14;
        ctx.beginPath();
        ctx.moveTo(-20,0);
        ctx.lineTo(80,0);
        ctx.stroke();
        ctx.restore();

        // write minutes
        ctx.save();
        ctx.rotate( (Math.PI/30)*min + (Math.PI/1800)*sec )
        ctx.lineWidth = 10;
        ctx.beginPath();
        ctx.moveTo(-28,0);
        ctx.lineTo(112,0);
        ctx.stroke();
        ctx.restore();

        // write seconds
        ctx.save();
        ctx.rotate(sec * Math.PI/30);
        ctx.strokeStyle = "#D40000";
        ctx.fillStyle = "#D40000";
        ctx.lineWidth = 6;
        ctx.beginPath();
        ctx.moveTo(-30,0);
        ctx.lineTo(83,0);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(0,0,10,0,Math.PI*2,true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(95,0,10,0,Math.PI*2,true);
        ctx.stroke();
        ctx.fillStyle = "#555";
        ctx.arc(0,0,3,0,Math.PI*2,true);
        ctx.fill();
        ctx.restore();

        ctx.beginPath();
        ctx.lineWidth = 14;
        ctx.strokeStyle = '#325FA2';
        ctx.arc(0,0,142,0,Math.PI*2,true);
        ctx.stroke();

        ctx.restore();
    };
    
    var clockChangeObserver = function() {
        showTime(clockModel.getTime());
    };

    var setClockModel = function(cm) {
        if (!cm) {
            throw new Error('must supply a clock model');
        }
        if (clockModel) {
            clockModel.removeChangeObserver(clockChangeObserver);
        }
        clockModel = cm;
        clockModel.addChangeObserver(clockChangeObserver);
        showTime(clockModel.getTime());
    };

    setClockModel(initialClockModel);

    return {
        getRootEl: function() {
            return rootEl;
        },
        setClockModel: setClockModel
    };
};


// A combination view & controller widget that manipulates a clock model.
//
var makeClockKnobsWidget = function(initialClockModel) {

    var clockModel;
    
    var rootEl = document.createElement('div');

    var startButton = document.createElement('div');
    startButton.innerHTML = 'start';
    startButton.addEventListener('click', function() {clockModel.start();}, false);
    rootEl.appendChild(startButton);
    
    var stopButton = document.createElement('div');
    stopButton.innerHTML = 'stop';
    stopButton.addEventListener('click', function() {clockModel.stop();}, false);
    rootEl.appendChild(stopButton);

    var resetButton = document.createElement('div');
    resetButton.innerHTML = 'reset';
    resetButton.addEventListener('click', function() {clockModel.resetTime();}, false);
    rootEl.appendChild(resetButton);

    var setClockModel = function(cm) {
        if (!cm) {
            throw new Error('must supply a clock model');
        }
        clockModel = cm;
    };
    
    setClockModel(initialClockModel);
    
    return {
        getRootEl: function() {
            return rootEl;
        },
        setClockModel: setClockModel
    };
};




// Bootstrap the clock app.
// Bootstrapping is always a bit of a messy process.
//
window.addEventListener('load', function() {
    
    var clockModel = makeClockModel();
                
    var analogClockWidget = makeAnalogClockWidget(clockModel);
    var digitalClockWidget = makeDigitalClockWidget(clockModel);
    var clockKnobsWidget = makeClockKnobsWidget(clockModel);
    
    document.body.appendChild(analogClockWidget.getRootEl());
    document.body.appendChild(digitalClockWidget.getRootEl());
    document.body.appendChild(clockKnobsWidget.getRootEl());
}, false);