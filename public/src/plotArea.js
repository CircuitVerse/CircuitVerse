import simulationArea from './simulationArea';

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


// var 

/**
 * @type {Object} plotArea
 * @category plotArea
 */
const plotArea = {
    ox: 0,
    oy: 0,
    unit: 0,
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
    scroll: 1,
    width: 0,
    height: 0,
    unitUsed: 0,
    cycleUnit: 10000,
    reset() {
        this.cycleCount = 0;
        this.cycleTime = new Date().getTime();
        for (var i = 0; i < globalScope.Flag.length; i++) {
            globalScope.Flag[i].plotValues = [[0, globalScope.Flag[i].inp1.value]];
            globalScope.Flag[i].cachedIndex = 0;
        }
        this.scroll = 1;
        this.unitUsed = 0;
    },
    nextCycle() {
        this.cycleCount++;
        this.cycleTime = new Date().getTime();
    },
    setExecutionTime() {
        this.executionStartTime = new Date().getTime();
    },
    resize() {
        this.DPR = window.devicePixelRatio || 1;
        this.DPR = 1;
        var oldHeight = this.height;
        var oldWidth = this.width;
        this.width = document.getElementById('plot').clientWidth * this.DPR;
        this.height = (globalScope.Flag.length * 30 + 30) * this.DPR;
        if (oldHeight == this.height && oldWidth == this.width) return;
        this.canvas.width = this.width;
        this.canvas.height = this.height;
        document.getElementById('plotArea').style.height = this.canvas.height / this.DPR;
        document.getElementById('plotArea').style.width = this.canvas.width / this.DPR;
    },
    setup() {
        this.canvas = document.getElementById('plotArea');
        if (!embed) {
            this.ctx = this.canvas.getContext('2d');
            setupTimingListeners();
        }
        this.timeOutPlot = setInterval(() => {
            plotArea.plot();
        }, 100);
        this.reset();
    },
    getPlotTime(timeUnit) {
        var time = this.cycleCount * this.cycleUnit;
        time += timeUnit;
        // For user interactions like buttons
        var timePeriod = simulationArea.timePeriod;
        var executionDelay = (this.executionStartTime - this.cycleTime);
        var delayFraction = executionDelay / timePeriod; 
        time += delayFraction * this.cycleUnit; 
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
            var recommendedUnit = Math.round(unitUsed * 1.2);
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

        if (this.scroll) {
            this.ox = Math.max(0, (time / this.unit) * this.pixel - this.canvas.width + 70);
        } else if (!plotArea.mouseDown) {
            this.ox -= plotArea.scrollAcc;
            plotArea.scrollAcc *= 0.95;
            if (this.ox < 0) plotArea.scrollAcc = -0.2 + 0.2 * this.ox;
            if (Math.abs(this.ox) < 0.5) this.ox = 0;
        }

        // Reset canvas
        var ctx = this.canvas.getContext('2d');
        this.clear(ctx);

         // Background Color
        ctx.fillStyle = 'black';
        ctx.fillRect(0, 0, this.width, this.height);

        var unit = (this.pixel / (plotArea.unit * plotArea.scale));
        ctx.strokeStyle = 'cyan';
        ctx.lineWidth = 2;
        ctx.fillStyle = '#eee';
        ctx.rect(0, 0, 75, this.canvas.height);
        ctx.fill();

        ctx.font = '15px Georgia';
        ctx.fillStyle = 'black';

        for (var i = 0; i < globalScope.Flag.length; i++) {
            ctx.fillText(globalScope.Flag[i].identifier, 5, 2 * (25 + i * 15) - plotArea.oy);
            ctx.fillRect(0, 2 * (13 + i * 15) + 4 - plotArea.oy, 75, 3);
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
        //                 ctx.font = '12px Georgia';
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

        ctx.fillStyle = '#eee';
        ctx.fillRect(0, 0, this.canvas.width, 30);
        ctx.font = '14px Georgia';
        ctx.fillStyle = 'black';
        console.log(plotArea.unit, plotArea.scale, time);
        return;
        for (var i = 1; i * Math.round(plotArea.unit * plotArea.scale) <= time + Math.round(plotArea.unit * plotArea.scale); i++) {
            console.log(i);
            ctx.fillText(`${Math.round(plotArea.unit * plotArea.scale) * i / 1000}s`, 48 + this.pixel * i - plotArea.ox, 20);
        }
        return;
        ctx.fillStyle = '#eee';
        ctx.fillRect(0, 0, 75, 30);
        ctx.fillStyle = 'black';
        ctx.font = '16px Georgia';
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
            ctx.font = '12px Georgia';
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
        var x = e.clientX - rect.left;
        plotArea.scrollAcc = 0;
        if (e.shiftKey) {
            plotArea.specificTimeX = x;
        } else {
            plotArea.scroll = 0;
            plotArea.mouseDown = true;

            plotArea.prevX = x;
        }
    });
    document.getElementById('plotArea').addEventListener('mouseup', (e) => {
        plotArea.mouseDown = false;
    });

    document.getElementById('plotArea').addEventListener('mousemove', (e) => {
        var rect = plotArea.canvas.getBoundingClientRect();
        var x = e.clientX - rect.left;
        if (!e.shiftKey && plotArea.mouseDown) {
            plotArea.ox -= x - plotArea.prevX;
            plotArea.scrollAcc = x - plotArea.prevX;
            plotArea.prevX = x;
            // plotArea.ox=Math.max(0,plotArea.ox)
        } else {
            plotArea.mouseDown = false;
        }
    });
}
