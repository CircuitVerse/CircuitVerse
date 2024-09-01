import { EventQueue } from '../eventQueue'
export interface SimulationArea {
    canvas: HTMLCanvasElement;
    context: CanvasRenderingContext2D|null;
    selected: boolean;
    hover: boolean;
    clockState: number;
    clockEnabled: boolean;
    // TODO: make this CircuitElement|null once converted to typescript
    lastSelected: any|null;
    stack: any[];
    prevScale: number;
    oldx: number;
    oldy: number;
    objectList: any[];
    maxHeight: number;
    maxWidth: number;
    minHeight: number;
    minWidth: number;
    multipleObjectSelections: any[];
    copyList: any[];
    shiftDown: boolean;
    controlDown: boolean;
    timePeriod: number;
    mouseX: number;
    mouseY: number;
    mouseDownX: number;
    mouseDownY: number;
    simulationQueue: EventQueue;
    clickCount: number;
    lock: string;
    mouseDown: boolean;
    ClockInterval: NodeJS.Timeout|null;
    touch: boolean;
    timer: () => void;
    setup: () => void;
    changeClockTime: (t: number) => void;
    clear: () => void;
}