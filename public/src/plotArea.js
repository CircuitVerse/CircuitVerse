import simulationArea from './simulationArea';
import {convertors} from './utils';

/**
 * @module plotArea
 * @category plotArea
 */
/**
 * function to add the plotting div
 * @memberof module:plotArea
 * @category plotArea
 */
function addPlot() {
    plotArea.ox = 0;
    plotArea.oy = 0;
    plotArea.count = 0;
    plotArea.unit = 1000;// parseInt(prompt("Enter unit of time(in milli seconds)"));
    plotArea.specificTimeX = 0;
}

var DPR = window.devicePixelRatio || 1;

function sh(x) {
    return x * DPR;
}

var frameInterval = 100;
var timeLineHeight = sh(20);
var padding = sh(2);
var plotHeight = sh(20);
var waveFormPadding = sh(5);
var waveFormHeight = plotHeight - 2 * waveFormPadding;
var flagLabelWidth = sh(75);
var cycleWidth = sh(30);
var backgroundColor = 'black';
var foregroundColor = '#eee';
var textColor = 'black';
var waveFormColor = 'cyan';
var timeLineStartX = flagLabelWidth + padding;

function getFullHeight(flagCount) {
    return timeLineHeight + (plotHeight + padding) * flagCount;
}

function getFlagStartY(flagIndex) {
    return getFullHeight(flagIndex) + padding;
}

function getCycleStartX(cycleNumber) {
    return timeLineStartX + (cycleNumber - plotArea.cycleOffset) * cycleWidth;
}

/**
 * @type {Object} plotArea
 * @category plotArea
 */
const plotArea = {
    cycleOffset: 0,
    unit: 0,
    DPR: window.devicePixelRatio || 1,
    canvas: document.getElementById('plotArea'),
    cycleCount: 0,
    cycleTime: 0,
    executionStartTime: 0,
    count: 0,
    specificTimeX: 0,
    scale: 1,
    pixel: 100,
    startTime: new Date(),
    endTime: new Date(),
    autoScroll: true,
    width: 0,
    height: 0,
    unitUsed: 0,
    cycleUnit: 1000,
    mouseDown: false,
    reset() {
        this.cycleCount = 0;
        this.cycleTime = new Date().getTime();
        for (var i = 0; i < globalScope.Flag.length; i++) {
            globalScope.Flag[i].plotValues = [[0, globalScope.Flag[i].inp1.value]];
            globalScope.Flag[i].cachedIndex = 0;
        }
        this.autoScroll = true;
        this.unitUsed = 0;
        this.resize();
    },
    resume() {
        this.autoScroll = true;
    },
    nextCycle() {
        this.cycleCount++;
        this.cycleTime = new Date().getTime();
    },
    setExecutionTime() {
        this.executionStartTime = new Date().getTime();
    },
    resize() {
        var oldHeight = this.height;
        var oldWidth = this.width;
        this.width = document.getElementById('plot').clientWidth * this.DPR;
        this.height = getFullHeight(globalScope.Flag.length);
        if (oldHeight == this.height && oldWidth == this.width) return;
        this.canvas.width = this.width;
        this.canvas.height = this.height;
        document.getElementById('plotArea').style.height = this.canvas.height / this.DPR;
        document.getElementById('plotArea').style.width = this.canvas.width / this.DPR;
        this.plot();
    },
    setup() {
        this.canvas = document.getElementById('plotArea');
        if (!embed) {
            this.ctx = this.canvas.getContext('2d');
            setupTimingListeners();
        }
        this.timeOutPlot = setInterval(() => {
            plotArea.plot();
        }, frameInterval);
        this.reset();
    },
    getPlotTime(timeUnit, delay = undefined) {
        var time = this.cycleCount;
        time += timeUnit / this.cycleUnit;
        // For user interactions like buttons
        var timePeriod = simulationArea.timePeriod;
        var executionDelay = (this.executionStartTime - this.cycleTime);
        var delayFraction = executionDelay / timePeriod; 
        time += delayFraction; 
        return time;
    },
    calibrate() {
        var recommendedUnit = Math.max(20, Math.round(this.unitUsed * 3));
        this.cycleUnit = recommendedUnit;
        $('#timing-diagram-units').val(recommendedUnit);
        this.reset();
    },
    getCurrentTime() {
        var time = this.cycleCount;
        var timePeriod = simulationArea.timePeriod;
        var delay = new Date().getTime() - this.cycleTime;
        var delayFraction = delay / timePeriod; 
        time += delayFraction; 
        return time;
    },
    plot() {
        if (embed) return;
        if (globalScope.Flag.length == 0) {
            this.canvas.width = this.canvas.height = 0;
            return;
        }
        this.resize();
        var dangerColor = '#dc5656';
        var normalColor = '#42b983';
        this.unitUsed = Math.max(this.unitUsed, simulationArea.simulationQueue.time);
        var unitUsed = this.unitUsed;
        var units = this.cycleUnit;
        var utilization = Math.round(unitUsed * 10000 / units) / 100;
        $('#timing-diagram-log').html(`Utilization: ${Math.round(unitUsed)} Units (${utilization}%)`);
        if (utilization >= 90 || utilization <= 10) {
            var recommendedUnit = Math.max(20, Math.round(unitUsed * 3));
            $('#timing-diagram-log').append(` Recommended Units: ${recommendedUnit}`);
            $('#timing-diagram-log').css('background-color', dangerColor);
            if (utilization >= 100) {
                this.clear();
                return;
            }
        }
        else {
            $('#timing-diagram-log').css('background-color', normalColor);
        }
        
        var time = this.cycleCount;
        var width = this.width;
        var height = this.height;
        
        // Calculating endTime
        var endTime = this.getCurrentTime();
        if (this.autoScroll) {
            // Formula used: 
            // (endTime - x) * cycleWidth = width - timeLineStartX;
            // x = endTime - (width - timeLineStartX) / cycleWidth
            this.cycleOffset = Math.max(0, endTime - (width - timeLineStartX) / cycleWidth);
        } else if (!plotArea.mouseDown) {
            // Scroll
            this.cycleOffset -= plotArea.scrollAcc;
            // Friction
            plotArea.scrollAcc *= 0.95;
            // No negative numbers allowed, so negative scroll to 0
            if (this.cycleOffset < 0) 
                plotArea.scrollAcc = this.cycleOffset / 5;
            // Set position to 0, to avoid infinite scrolling 
            if (Math.abs(this.cycleOffset) < 0.01) this.cycleOffset = 0;
        }

        // Reset canvas
        var ctx = this.canvas.getContext('2d');
        this.clear(ctx);
        ctx.lineWidth = sh(1);

         // Background Color
        ctx.fillStyle = backgroundColor;
        ctx.fillRect(0, 0, width, height);

        ctx.font = `${sh(15)}px Raleway`;
        ctx.textAlign = 'left';

        // Timeline
        ctx.fillStyle = foregroundColor;
        ctx.fillRect(timeLineStartX, 0, this.canvas.width, timeLineHeight);
        ctx.fillRect(0, 0, flagLabelWidth, timeLineHeight);
        ctx.fillStyle = textColor;
        ctx.fillText('Time', sh(5), timeLineHeight * 0.7);

        // Timeline numbers
        ctx.font = `${sh(9)}px Times New Roman`;
        ctx.strokeStyle = textColor;
        ctx.textAlign = 'center';
        for (var i = Math.floor(plotArea.cycleOffset); getCycleStartX(i) <= width ; i++) {
            var x = getCycleStartX(i);
            if (x >= timeLineStartX) {
                ctx.fillText(`${i}`, x, timeLineHeight - sh(15)/2);
                ctx.beginPath();
                ctx.moveTo(x, timeLineHeight - sh(5));
                ctx.lineTo(x, timeLineHeight);
                ctx.stroke();
            }
            for(var j = 1; j < 5; j++) {
                var x1 = x + Math.round(j * cycleWidth / 5);
                if (x1 >= timeLineStartX) {
                    ctx.beginPath();
                    ctx.moveTo(x1, timeLineHeight - sh(2));
                    ctx.lineTo(x1, timeLineHeight);
                    ctx.stroke();
                }
            }
        }
        
        // Labels
        ctx.textAlign = 'left';
        for (var i = 0; i < globalScope.Flag.length; i++) {
            var startHeight = getFlagStartY(i); 
            ctx.fillStyle = foregroundColor;
            ctx.fillRect(0, startHeight, flagLabelWidth, plotHeight);
            ctx.fillStyle = textColor;
            ctx.fillText(globalScope.Flag[i].identifier, sh(5), startHeight + plotHeight * 0.7);
        }

        const WAVEFORM_NOT_STARTED = 0;
        const WAVEFORM_STARTED = 1;
        const WAVEFORM_OVER = 3;


        // Waveform
        ctx.strokeStyle = waveFormColor;
        ctx.textAlign = 'center';
        var endX = Math.min(getCycleStartX(endTime), width);
        
        for (var i = 0; i < globalScope.Flag.length; i++) {
            var plotValues = globalScope.Flag[i].plotValues;
            var startHeight = getFlagStartY(i) + waveFormPadding;
            var yTop = startHeight;
            var yMid = startHeight + waveFormHeight / 2;
            var yBottom = startHeight + waveFormHeight;
            var state = WAVEFORM_NOT_STARTED;
            var prevY;

            var j = 0;
            if (globalScope.Flag[i].cachedIndex) { 
                j = globalScope.Flag[i].cachedIndex; 
            }

            while (j + 1 < plotValues.length && getCycleStartX(plotValues[j][0]) < timeLineStartX) {
                j++;
            }

            while (j > 0 && getCycleStartX(plotValues[j][0]) > timeLineStartX) {
                j--;
            }

            globalScope.Flag[i].cachedIndex = j;

            for (; j < plotValues.length; j++) {
                var x = getCycleStartX(plotValues[j][0]);

                // Handle out of bound
                if (x < timeLineStartX) {
                    if(j + 1 != plotValues.length) {
                        // Next one also is out of bound, so skip this one completely
                        var x1 = getCycleStartX(plotValues[j + 1][0]);
                        if (x1 < timeLineStartX) 
                            continue;
                    }
                    x = timeLineStartX;
                }
                
                var value = plotValues[j][1];
                if(value === undefined) {
                    if (state == WAVEFORM_STARTED) {
                        ctx.stroke();
                    }
                    state = WAVEFORM_NOT_STARTED;
                    continue;
                }
                if (globalScope.Flag[i].bitWidth == 1) {
                    if (x > endX) break;
                    var y = value == 1 ? yTop : yBottom;
                    if (state == WAVEFORM_NOT_STARTED) {
                        // Start new plot
                        state = WAVEFORM_STARTED;
                        ctx.beginPath();
                        ctx.moveTo(x, y);
                    }
                    else {
                        ctx.lineTo(x, prevY);
                        ctx.lineTo(x, y);
                    }
                    prevY = y;
                }
                else {
                    var endX;
                    if (j + 1 == plotValues.length) {
                        endX = getCycleStartX(endTime);
                    }
                    else {
                        endX = getCycleStartX(plotValues[j + 1][0]);
                    }
                    var smallOffset = waveFormHeight / 2;
                    ctx.beginPath();
                    ctx.moveTo(endX, yMid);
                    ctx.lineTo(endX - smallOffset, yTop);
                    ctx.lineTo(x + smallOffset, yTop);
                    ctx.lineTo(x, yMid);
                    ctx.lineTo(x + smallOffset, yBottom);
                    ctx.lineTo(endX - smallOffset, yBottom);
                    ctx.closePath();
                    ctx.stroke();

                    // Text position
                    // Clamp start and end are within the screen
                    var x1 = Math.max(x, timeLineStartX);
                    var x2 = Math.min(endX, width);
                    var textPositionX = (x1 + x2) / 2 ;
                    
                    ctx.font = `${sh(9)}px Times New Roman`;
                    ctx.fillStyle = 'white';
                    ctx.fillText(convertors.dec2hex(value), textPositionX, yMid + sh(3));
                }
                if (x > width) {
                    state = WAVEFORM_OVER;
                    ctx.stroke();
                    break;
                }
            }
            if (state == WAVEFORM_STARTED) {
                if (globalScope.Flag[i].bitWidth == 1) {
                    ctx.lineTo(endX, prevY);
                }
                ctx.stroke();
            }
        }
        
        // for (var i = 0; i < globalScope.Flag.length; i++) {
        //     var arr = globalScope.Flag[i].plotValues;
        //     console.log(i, arr);
        //     var j = 0;
        //     // var start=arr[j][0];
        //     if (globalScope.Flag[i].cachedIndex) { 
        //         j = globalScope.Flag[i].cachedIndex; 
        //     }

        //     while (j < arr.length && 80 + (arr[j][0] * unit) - plotArea.ox < 0) {
        //         j++;
        //     }
        //     while (j < arr.length && j > 0 && 80 + (arr[j][0] * unit) - plotArea.ox > 0) {
        //         j--;
        //     }
        //     if (j) j--;
        //     globalScope.Flag[i].cachedIndex = j;
        //     console.log("HIT");
        //     continue;

        //     for (; j < arr.length; j++) {
        //         var start = arr[j][0];

        //         if (j + 1 == arr.length) { var end = time; } else { var end = arr[j + 1][0]; }

        //         if (start <= time) {
        //             if (globalScope.Flag[i].bitWidth == 1) {
        //                 if (arr[j][1] !== undefined) {
        //                     if (ctx.strokeStyle == '#000000') {
        //                         ctx.stroke();
        //                         ctx.beginPath();
        //                         ctx.lineWidth = 2;
        //                         //   ctx.moveTo(80+(start*unit)-plotArea.ox,2*(30+i*15-yOff)-plotArea.oy)
        //                         ctx.strokeStyle = 'cyan';
        //                     }
        //                     var yOff = 5 * arr[j][1];
        //                 } else {
        //                     ctx.stroke();
        //                     ctx.beginPath();
        //                     // ctx.moveTo(80+(start*unit)-plotArea.ox,2*(30+i*15-yOff)-plotArea.oy);
        //                     ctx.lineWidth = 12;
        //                     ctx.strokeStyle = '#000000'; // DIABLED Z STATE FOR NOW
        //                     yOff = 2.5;
        //                 }
        //                 ctx.lineTo(80 + (start * unit) - plotArea.ox, 2 * (30 + i * 15 - yOff) - plotArea.oy);
        //                 ctx.lineTo(80 + (end * unit) - plotArea.ox, 2 * (30 + i * 15 - yOff) - plotArea.oy);
        //             } else {
        //                 ctx.beginPath();
        //                 ctx.moveTo(80 + (end * unit) - plotArea.ox, 55 + 30 * i - plotArea.oy);
        //                 ctx.lineTo(80 + (end * unit) - 5 - plotArea.ox, 2 * (25 + i * 15) - plotArea.oy);
        //                 ctx.lineTo(80 + (start * unit) + 5 - plotArea.ox, 2 * (25 + i * 15) - plotArea.oy);
        //                 ctx.lineTo(80 + (start * unit) - plotArea.ox, 55 + 30 * i - plotArea.oy);
        //                 ctx.lineTo(80 + (start * unit) + 5 - plotArea.ox, 2 * (30 + i * 15) - plotArea.oy);
        //                 ctx.lineTo(80 + (end * unit) - 5 - plotArea.ox, 2 * (30 + i * 15) - plotArea.oy);
        //                 ctx.lineTo(80 + (end * unit) - plotArea.ox, 55 + 30 * i - plotArea.oy);
        //                 var mid = 80 + ((end + start) / Math.round(plotArea.unit * plotArea.scale)) * this.pixel / 2;
        //                 ctx.font = '12px Raleway';
        //                 ctx.fillStyle = 'white';
        //                 if ((start * unit) + 10 - plotArea.ox <= 0 && (end * unit) + 10 - plotArea.ox >= 0) {
        //                     mid = 80 + ((end - 3000) / Math.round(plotArea.unit * plotArea.scale)) * this.pixel;
        //                 }

        //                 ctx.fillText(arr[j][1].toString() || 'x', mid - plotArea.ox, 57 + 30 * i - plotArea.oy);
        //                 ctx.stroke();
        //             }
        //         } else {
        //             break;
        //         }

        //         if (80 + (end * unit) - plotArea.ox > this.canvas.width) break;
        //     }

        //     ctx.stroke();
        //     ctx.beginPath();
        // }
        // 2 rectangles showing the time and labels

        return;
        
        return;
        ctx.fillStyle = '#eee';
        ctx.fillRect(0, 0, 75, 30);
        ctx.fillStyle = 'black';
        ctx.font = '16px Raleway';
        ctx.fillText('Time', 10, 20);
        ctx.strokeStyle = 'black';
        ctx.moveTo(0, 25);
        ctx.lineTo(75, 25);
        // for yellow line to show specific time
        var specificTime = (plotArea.specificTimeX + plotArea.ox - 80) * Math.round(plotArea.unit * plotArea.scale) / (this.pixel);
        // ctx.strokeStyle = 'white';
        // ctx.moveTo(plotArea.specificTimeX,0);
        // ctx.lineTo(plotArea.specificTimeX,plotArea.canvas.height);
        // ctx.stroke();
        if (1.115 * plotArea.specificTimeX >= 80) {
            ctx.fillStyle = 'black';
            ctx.fillRect(plotArea.specificTimeX - 35, 0, 70, 30);
            ctx.fillStyle = 'red';
            ctx.fillRect(plotArea.specificTimeX - 30, 2, 60, 26);
            ctx.font = '12px Raleway';
            ctx.fillStyle = 'black';
            ctx.fillText(`${Math.round(specificTime)}ms`, plotArea.specificTimeX - 25, 20);
        }
        // borders
        ctx.strokeStyle = 'black';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.lineTo(0, this.canvas.height);
        //   ctx.fillRect(0, 0, 3, this.canvas.height);

        ctx.moveTo(74, 0);
        ctx.lineTo(74, this.canvas.height);
        //   ctx.fillRect(74, 0, 3, this.canvas.height);

        ctx.moveTo(0, 0);
        ctx.lineTo(this.canvas.width, 0);
        //   ctx.fillRect(0, 0, this.canvas.width, 3);

        // ctx.moveTo(0,27);
        // ctx.lineTo(this.canvas.width,27);
        //   ctx.fillRect(0, 27, this.canvas.width, 3);
        ctx.stroke();
    },
    clear() {
        this.ctx.clearRect(0, 0, plotArea.canvas.width, plotArea.canvas.height);
    },

};
export default plotArea;

function setupTimingListeners() {
    $('.timing-diagram-smaller').on('click', () => {
        $('#plot').width($('#plot').width() - 20)
        plotArea.resize();
    })
    $('.timing-diagram-larger').on('click', () => {
        $('#plot').width($('#plot').width() + 20)
        plotArea.resize();
    })
    $('.timing-diagram-reset').on('click', () => {
        plotArea.reset();
    })
    $('.timing-diagram-calibrate').on('click', () => {
        plotArea.calibrate();
    })
    $('.timing-diagram-resume').on('click', () => {
        plotArea.resume();
    })
    $('#timing-diagram-units').on('change paste keyup', function() {
        var timeUnits = parseInt($(this).val(), 10);
        if (isNaN(timeUnits) || timeUnits < 1) return;
        plotArea.cycleUnit = timeUnits;
    })
    document.getElementById('plotArea').addEventListener('mousedown', (e) => {
        var rect = plotArea.canvas.getBoundingClientRect();
        var x = sh(e.clientX - rect.left);
        plotArea.scrollAcc = 0;
        plotArea.autoScroll = false;
        plotArea.mouseDown = true;
        plotArea.prevX = x;
        plotArea.mouseDownX = x;
        plotArea.mouseDownTime = new Date().getTime();
    });
    document.getElementById('plotArea').addEventListener('mouseup', (e) => {
        plotArea.mouseDown = false;
        var time = new Date().getTime() - plotArea.mouseDownTime;
        var offset = (plotArea.prevX - plotArea.mouseDownX) / cycleWidth;
        console.log(offset, time);
        plotArea.scrollAcc = offset * frameInterval / time;
    });

    document.getElementById('plotArea').addEventListener('mousemove', (e) => {
        var rect = plotArea.canvas.getBoundingClientRect();
        var x = sh(e.clientX - rect.left);
        if (plotArea.mouseDown) {
            plotArea.cycleOffset -= (x - plotArea.prevX) / cycleWidth;
            plotArea.prevX = x;
        } else {
            plotArea.mouseDown = false;
        }
    });
}
