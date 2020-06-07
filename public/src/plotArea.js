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

/**
 * Used as a stopwatch to
 * record time side of the plot
 * @category plotArea
 */
class StopWatch {
    constructor() {
        this.StartMilliseconds = 0;
        this.ElapsedMilliseconds = 0;
    }

    /**
     * @memberof StopWatch
     * used to start the stopwatch
     */
    Start() {
        this.StartMilliseconds = new Date().getTime();
    }

    /**
    * @memberof StopWatch
    * used to get time elapsed.
    */
    Stop() {
        this.ElapsedMilliseconds = new Date().getTime() - this.StartMilliseconds;
    }
}

/**
 * @type {Object} plotArea
 * @category plotArea
 */
const plotArea = {
    ox: 0,
    oy: 0,
    unit: 0,
    c: document.getElementById('plotArea'),

    count: 0,
    specificTimeX: 0,
    scale: 1,
    pixel: 100,
    startTime: new Date(),
    endTime: new Date(),
    scroll: 1,
    setup() {
        this.c = document.getElementById('plotArea');
        this.stopWatch = new StopWatch();
        this.stopWatch.Start();
        this.ctx = this.c.getContext('2d');
        startPlot();
        this.timeOutPlot = setInterval(() => {
            plotArea.plot();
        }, 100);
    },
    plot() {
        if (globalScope.Flag.length == 0) {
            this.c.width = this.c.height = 0;
            return;
        }
        this.stopWatch.Stop();
        const time = this.stopWatch.ElapsedMilliseconds;
        this.c.width = document.getElementById('simulationArea').clientWidth; // innerWidth;

        this.c.height = globalScope.Flag.length * 30 + 40;

        // if(document.getElementById("plot").style.height!=this.c.height+"px"){
        document.getElementById('plot').style.height = Math.min(this.c.height, 400);
        document.getElementById('plot').style.width = this.c.width;
        // }
        // else if(document.getElementById("plot").style.width!=this.c.width+"px"){
        // document.getElementById("plot").style.height = this.c.height ;
        // document.getElementById("plot").style.width = this.c.width ;
        // }

        if (this.scroll) {
            this.ox = Math.max(0, (time / this.unit) * this.pixel - this.c.width + 70);
        } else if (!plotArea.mouseDown) {
            this.ox -= plotArea.scrollAcc;
            plotArea.scrollAcc *= 0.95;
            if (this.ox < 0) plotArea.scrollAcc = -0.2 + 0.2 * this.ox;
            if (Math.abs(this.ox) < 0.5) this.ox = 0;
        }
        const { ctx } = this;
        this.clear(ctx);
        ctx.fillStyle = 'black';
        ctx.fillRect(0, 0, this.c.width, this.c.height);
        const unit = (this.pixel / (plotArea.unit * plotArea.scale));
        ctx.strokeStyle = 'cyan';
        ctx.lineWidth = 2;
        for (let i = 0; i < globalScope.Flag.length; i++) {
            const arr = globalScope.Flag[i].plotValues;

            let j = 0;
            // let start=arr[j][0];
            if (globalScope.Flag[i].cachedIndex) { j = globalScope.Flag[i].cachedIndex; }


            while (j < arr.length && 80 + (arr[j][0] * unit) - plotArea.ox < 0) {
                // console.log("HIT2");
                j++;
                // start=
            }
            while (j < arr.length && j > 0 && 80 + (arr[j][0] * unit) - plotArea.ox > 0) {
                // console.log("HIT1");
                j--;
                // start=
            }
            if (j) j--;
            globalScope.Flag[i].cachedIndex = j;

            for (; j < arr.length; j++) {
                const start = arr[j][0];
                let end;
                if (j + 1 == arr.length) { end = time; } else { end = arr[j + 1][0]; }
                let yOff;
                if (start <= time) {
                    if (globalScope.Flag[i].bitWidth == 1) {
                        if (arr[j][1] !== undefined) {
                            if (ctx.strokeStyle == '#000000') {
                                ctx.stroke();
                                ctx.beginPath();
                                ctx.lineWidth = 2;
                                //   ctx.moveTo(80+(start*unit)-plotArea.ox,2*(30+i*15-yOff)-plotArea.oy)
                                ctx.strokeStyle = 'cyan';
                            }
                            yOff = 5 * arr[j][1];
                        } else {
                            ctx.stroke();
                            ctx.beginPath();
                            // ctx.moveTo(80+(start*unit)-plotArea.ox,2*(30+i*15-yOff)-plotArea.oy);
                            ctx.lineWidth = 12;
                            ctx.strokeStyle = '#000000'; // DIABLED Z STATE FOR NOW
                            yOff = 2.5;
                        }
                        ctx.lineTo(80 + (start * unit) - plotArea.ox, 2 * (30 + i * 15 - yOff) - plotArea.oy);
                        ctx.lineTo(80 + (end * unit) - plotArea.ox, 2 * (30 + i * 15 - yOff) - plotArea.oy);
                    } else {
                        ctx.beginPath();
                        ctx.moveTo(80 + (end * unit) - plotArea.ox, 55 + 30 * i - plotArea.oy);
                        ctx.lineTo(80 + (end * unit) - 5 - plotArea.ox, 2 * (25 + i * 15) - plotArea.oy);
                        ctx.lineTo(80 + (start * unit) + 5 - plotArea.ox, 2 * (25 + i * 15) - plotArea.oy);
                        ctx.lineTo(80 + (start * unit) - plotArea.ox, 55 + 30 * i - plotArea.oy);
                        ctx.lineTo(80 + (start * unit) + 5 - plotArea.ox, 2 * (30 + i * 15) - plotArea.oy);
                        ctx.lineTo(80 + (end * unit) - 5 - plotArea.ox, 2 * (30 + i * 15) - plotArea.oy);
                        ctx.lineTo(80 + (end * unit) - plotArea.ox, 55 + 30 * i - plotArea.oy);
                        mid = 80 + ((end + start) / Math.round(plotArea.unit * plotArea.scale)) * this.pixel / 2;
                        ctx.font = '12px Georgia';
                        ctx.fillStyle = 'white';
                        if ((start * unit) + 10 - plotArea.ox <= 0 && (end * unit) + 10 - plotArea.ox >= 0) {
                            mid = 80 + ((end - 3000) / Math.round(plotArea.unit * plotArea.scale)) * this.pixel;
                        }


                        ctx.fillText(arr[j][1].toString() || 'x', mid - plotArea.ox, 57 + 30 * i - plotArea.oy);
                        ctx.stroke();
                    }
                } else {
                    break;
                }

                if (80 + (end * unit) - plotArea.ox > this.c.width) break;
            }

            ctx.stroke();
            ctx.beginPath();
        }
        // 2 rectangles showing the time and labels

        ctx.fillStyle = '#eee';
        ctx.fillRect(0, 0, this.c.width, 30);
        ctx.font = '14px Georgia';
        ctx.fillStyle = 'black';
        for (let i = 1; i * Math.round(plotArea.unit * plotArea.scale) <= time + Math.round(plotArea.unit * plotArea.scale); i++) {
            ctx.fillText(`${Math.round(plotArea.unit * plotArea.scale) * i / 1000}s`, 48 + this.pixel * i - plotArea.ox, 20);
        }

        ctx.fillStyle = '#eee';
        ctx.fillRect(0, 0, 75, this.c.height);
        ctx.font = '15px Georgia';
        ctx.fillStyle = 'black';
        for (let i = 0; i < globalScope.Flag.length; i++) {
            ctx.fillText(globalScope.Flag[i].identifier, 5, 2 * (25 + i * 15) - plotArea.oy);
            ctx.fillRect(0, 2 * (13 + i * 15) + 4 - plotArea.oy, 75, 3);
        }
        ctx.fillStyle = '#eee';
        ctx.fillRect(0, 0, 75, 30);
        ctx.fillStyle = 'black';
        ctx.font = '16px Georgia';
        ctx.fillText('Time', 10, 20);
        ctx.strokeStyle = 'black';
        ctx.moveTo(0, 25);
        ctx.lineTo(75, 25);
        // for yellow line to show specific time
        const specificTime = (plotArea.specificTimeX + plotArea.ox - 80) * Math.round(plotArea.unit * plotArea.scale) / (this.pixel);
        // ctx.strokeStyle = 'white';
        // ctx.moveTo(plotArea.specificTimeX,0);
        // ctx.lineTo(plotArea.specificTimeX,plotArea.c.height);
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
        ctx.lineTo(0, this.c.height);
        //   ctx.fillRect(0, 0, 3, this.c.height);

        ctx.moveTo(74, 0);
        ctx.lineTo(74, this.c.height);
        //   ctx.fillRect(74, 0, 3, this.c.height);

        ctx.moveTo(0, 0);
        ctx.lineTo(this.c.width, 0);
        //   ctx.fillRect(0, 0, this.c.width, 3);

        // ctx.moveTo(0,27);
        // ctx.lineTo(this.c.width,27);
        //   ctx.fillRect(0, 27, this.c.width, 3);
        ctx.stroke();
    },
    clear(ctx) {
        ctx.clearRect(0, 0, plotArea.c.width, plotArea.c.height);
        // clearInterval(timeOutPlot);
    },

};
export default plotArea;
if (document.getElementById('plotArea') !== null) {
    /**
     * Event listeners for the Plot
     */
    document.getElementById('plotArea').addEventListener('mousedown', (e) => {
        const rect = plotArea.c.getBoundingClientRect();
        const x = e.clientX - rect.left;
        plotArea.scrollAcc = 0;
        if (e.shiftKey) {
            plotArea.specificTimeX = x;
        } else {
            plotArea.scroll = 0;
            plotArea.mouseDown = true;

            plotArea.prevX = x;
            console.log('HIT');
        }
    });
    document.getElementById('plotArea').addEventListener('mouseup', (e) => {
        plotArea.mouseDown = false;
    });

    document.getElementById('plotArea').addEventListener('mousemove', (e) => {
        const rect = plotArea.c.getBoundingClientRect();
        const x = e.clientX - rect.left;
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
/**
 * sets plot values of all flags and it add(s)Plot().
 * @category plotArea
 */
function startPlot() {
    plotArea.stopWatch.Start();
    for (let i = 0; i < globalScope.Flag.length; i++) {
        globalScope.Flag[i].plotValues = [[0, globalScope.Flag[i].inp1.value]];
        globalScope.Flag[i].cachedIndex = 0;
    }
    // play();
    plotArea.scroll = 1;
    addPlot();
}
