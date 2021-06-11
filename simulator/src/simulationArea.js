/* eslint-disable semi */
/* eslint-disable no-undef */
/* eslint-disable import/no-cycle */
import EventQueue from './eventQueue';
import { clockTick } from './utils';

/**
 * simulation environment object - holds simulation canvas
 * @type {Object} simulationArea
 * @property {HTMLCanvasElement} canvas
 * @property {boolean} selected
 * @property {boolean} hover
 * @property {number} clockState
 * @property {boolean} clockEnabled
 * @property {undefined} lastSelected
 * @property {Array} stack
 * @property {number} prevScale
 * @property {number} oldx
 * @property {number} oldy
 * @property {Array} objectList
 * @property {number} maxHeight
 * @property {number} maxWidth
 * @property {number} minHeight
 * @property {number} minWidth
 * @property {Array} multipleObjectSelections
 * @property {Array} copyList - List of selected elements
 * @property {boolean} shiftDown - shift down or not
 * @property {boolean} controlDown - contol down or not
 * @property {number} timePeriod - time period
 * @property {number} x - mouse and touch x
 * @property {number} y - mouse and touch y
 * @property {number} DownX - mouse Click Or touch Tap  x
 * @property {number} DownY - mouse Click Or touch tap  y
 * @property {Array} simulationQueue - simulation queue
 * @property {number} clickCount - number of clicks
 * @property {string} lock - locked or unlocked
 * @property {function} timer - timer
 * @property {function} setup - to setup the simulaton area
 * @property {function} changeClockTime - change clock time
 * @property {function} clear - clear the simulation area
 * @category simulationArea
 */
const simulationArea = {
  canvas: document.getElementById('simulationArea'),
  selected: false,
  hover: false,
  clockState: 0,
  clockEnabled: true,
  lastSelected: undefined,
  stack: [],
  prevScale: 0,
  oldx: 0,
  oldy: 0,
  objectList: [],
  maxHeight: 0,
  maxWidth: 0,
  minHeight: 0,
  minWidth: 0,
  multipleObjectSelections: [],
  copyList: [],
  shiftDown: false,
  controlDown: false,
  timePeriod: 500,
  x: 0,
  y: 0,
  DownX: 0,
  DownY: 0,
  simulationQueue: undefined,
  multiAddElement: false,
  touch: false,

  clickCount: 0, // double click
  lock: 'unlocked',
  timer () {
    ckickTimer = setTimeout(() => {
      simulationArea.clickCount = 0;
    }, 600);
  },

  setup () {
    this.canvas = document.getElementById('simulationArea');
    this.canvas.width = width;
    this.canvas.height = height;
    this.simulationQueue = new EventQueue(10000);
    this.context = this.canvas.getContext('2d');
    simulationArea.changeClockTime(simulationArea.timePeriod);
    this.touchMouseDown = false;
  },
  changeClockTime (t) {
    if (t < 50) return;
    clearInterval(simulationArea.ClockInterval);
    t = t || prompt('Enter Time Period:');
    simulationArea.timePeriod = t;
    simulationArea.ClockInterval = setInterval(clockTick, t);
  },
  clear () {
    if (!this.context) return;
    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
  }
};
export const { changeClockTime } = simulationArea;
export default simulationArea;
