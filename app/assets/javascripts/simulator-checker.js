var simulatorDisabled = true;
var checkerRunning = false;
var mouseConnected = false;

function disableSimulator() {
    if (!simulatorDisabled) {
        $('main').addClass('hidden');
        $('#simulator-disabled').removeClass('hidden');

        simulatorDisabled = true;
    }
}
function enableSimulator() {
    if (simulatorDisabled) {
        $('main').removeClass('hidden');
        $('#simulator-disabled').addClass('hidden');

        simulatorDisabled = false;
    }
}

function checkScreenSize() {
    if (document.documentElement.clientWidth < 900) {
        return false;
    }
    return true;
}
function checkTouchScreenOne() {
    if (window.PointerEvent && ('maxTouchPoints' in navigator)) {
        // Check 1 - use navigator.maxTouchPoints
        if (navigator.maxTouchPoints > 0) {
            return true;
        }
    }
    return false;
}
function checkTouchScreenTwo() {
    // Check 2 - use match media
    if (window.matchMedia) {
        if (window.matchMedia('(any-pointer:coarse)').matches) {
            return true;
        }
    }
    return false;
}
function checkTouchScreenThree() {
    // Check 3 - use touch events
    if (window.TouchEvent || ('ontouchstart' in window)) {
        return true;
    }
    return false;
}
function hasTouchScreen() {
    if (checkTouchScreenOne() || checkTouchScreenTwo() || checkTouchScreenThree()) {
        return true;
    }
    return false;
}

function mouseIsConnected() {
    if (!mouseConnected) {
        $(window).off('mousemove');
        mouseConnected = true;
    }
}

function checkSimulator() {
    if (checkerRunning) {
        if (mouseConnected && checkScreenSize()) {
            enableSimulator();
        } else {
            disableSimulator();
        }
    }
}

function initialiseChecks() {
    checkerRunning = true;
    var touchscreen = hasTouchScreen();
    if (!touchscreen) {
        mouseIsConnected();
    }

    checkSimulator();
}

$(window).ready(initialiseChecks);
$(window).on('resize', checkSimulator);
$(window).on('mousemove', mouseIsConnected);
