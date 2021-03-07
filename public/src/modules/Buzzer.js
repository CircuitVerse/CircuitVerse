import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, lineTo, moveTo, arc } from '../canvasApi';
import { changeInputSize } from '../modules';
import { colors } from '../themer/themer';
import { gateGenerateVerilog } from '../utils';


export default class Buzzer extends CircuitElement {
	constructor(x, y, scope = globalScope, dir = 'RIGHT', bitWidth = 1 , volume = 10) {
        super(x, y, scope, dir, bitWidth);
        /* this is done in this.baseSetup() now
        this.scope['Adder'].push(this);
        */

		this.setDimensions(30, 30);
        this.changeInputSize = false ;
  
        this.Sharp = 0 ; 
        this.Flat = 0 ; 
        this.Volume = volume ; 
        this.completed = 0 ; 

        this.Frequency = new Node(-30, -20, 0, this, this.bitWidth, 'Freq');
    	this.Duration = new Node(-30, 0, 0, this, this.bitWidth, 'Dur');
    	this.start = new Node(-30, 20, 0, this, 1 , 'play'); 
    }


    newBitWidth(bitWidth) {
        this.bitWidth = bitWidth;
        this.Frequency.bitWidth = bitWidth;
        this.Duration.bitWidth = bitWidth;
    }


 	customSave() {
        const data = {
            constructorParamaters: [this.direction, this.bitWidth , this.volume],
            nodes: {
                Frequency: findNode(this.Frequency),
                Duration: findNode(this.Duration), 
                start: findNode(this.start),
            },
        };
        return data;
    }


	changeToSharp(val = 'on') {
	    	this.Sharp = 1 ; 
	    	// console.log(this.Sharp) ; 
	    }

	changeToFlat(val = 'on') {
	    	this.Flat = 1 ; 
	    }
	IncreaseVolume(number = 10) {
	    	this.Volume = number ; 
	        // console.log(this.Volume) ;

	    }


    isResolvable() {
        return (this.Frequency.value !== undefined || this.Duration.value !== undefined) ; 
    }

    resolve() {
    	if(this.isResolvable() === false) {
            return;
        }

        // console.log(this.Duration.value) ; 

        if((this.start.value === 1)&& (this.completed != this.Duration.value)){
        	// console.log("y") ;
        	var audioCtx = new(window.AudioContext || window.webkitAudioContext)(); 
	        var oscillator = audioCtx.createOscillator();
	        oscillator.type = 'square';
	        console.log(this.Volume/10) ;
	        var gainNode = audioCtx.createGain() ; 
	        gainNode.gain.value = this.Volume/10 ; 

	        
	        if(this.Sharp == 1) {
	        	// console.log("yes") ; 
	        	this.Sharp = 0 ; 
	 			oscillator.frequency.value = (this.Frequency.value)*Math.pow(2 , 1/12); // value in hertz
	 		}

	 		else if(this.Flat == 1) {
	 			this.Flat = 0 ; 
	 			oscillator.frequency.value = (this.Frequency.value)*Math.pow(2 , -1/12);
	 		}

	 		else{
	 			// console.log("yayayaya") ;
	 			oscillator.frequency.value = this.Frequency.value;
	 		}

	  		oscillator.connect(audioCtx.destination);
	  		oscillator.start();
	  		oscillator.stop(audioCtx.currentTime + this.Duration.value) ; 
	  		// console.log("yesssss") ;
	  		this.completed = this.Duration.value ; 
  		}

  		else {
  			this.completed = 0 ; 
  			// console.log("n") ; 
  			return; 
  		}

  		simulationArea.simulationQueue.add(this.Frequency);

    }

    customDraw() {
        var ctx = simulationArea.context;
        ctx.strokeStyle = colors["stroke_alt"];
        ctx.lineWidth = correctWidth(3);
        const xx = this.x;
        const yy = this.y;
        ctx.beginPath();
        ctx.fillStyle = "black";
        
        moveTo(ctx, 30, 20, xx, yy, this.direction);
        lineTo(ctx, 30, -20, xx, yy, this.direction);

        moveTo(ctx, 30, -20, xx, yy, this.direction);
        lineTo(ctx, 20, -30, xx, yy, this.direction);

        moveTo(ctx, 20, -30, xx, yy, this.direction);
        lineTo(ctx, -20, -30, xx, yy, this.direction);

        moveTo(ctx, -20, -30, xx, yy, this.direction);
        lineTo(ctx, -30, -20, xx, yy, this.direction);

        moveTo(ctx, -30, -20, xx, yy, this.direction);
        lineTo(ctx, -30, 20, xx, yy, this.direction);

        moveTo(ctx, -30, 20, xx, yy, this.direction);
        lineTo(ctx, -20, 30, xx, yy, this.direction);

        moveTo(ctx, -20, 30, xx, yy, this.direction);
        lineTo(ctx, 20, 30, xx, yy, this.direction);

        moveTo(ctx, 20, 30, xx, yy, this.direction);
        lineTo(ctx, 30, 20, xx, yy, this.direction);

        ctx.closePath();
        if (
            (this.hover && !simulationArea.shiftDown) ||
            simulationArea.lastSelected === this ||
            simulationArea.multipleObjectSelections.contains(this)
        )
        ctx.fillStyle = colors["hover_select"];
        
        ctx.fill();
        ctx.stroke();
    }
}


Buzzer.prototype.tooltipText =
    "Buzzer ToolTip : Isolate the frequency with duration and start";
Buzzer.prototype.objectType = "Buzzer";

Buzzer.prototype.mutableProperties = {
    Volume: {
        name: 'Volume',
        type: 'number',
        max : '20',
        func: 'IncreaseVolume',
    },
    Sharp: {
        name: 'Sharp',
        type: 'checkbox',
        func: 'changeToSharp',
    },
    Flat: {
        name: 'Flat',
        type: 'checkbox',
        func: 'changeToFlat',
    },
};