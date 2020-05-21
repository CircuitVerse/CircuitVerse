import AndGate from './modules/AndGate';
import NandGate from './modules/NandGate';
import Multiplexer from './modules/Multiplexer';
import XorGate from './modules/XorGate';
import XnorGate from './modules/XnorGate';
import SevenSegDisplay from './modules/SevenSegDisplay';
import SixteenSegDisplay from './modules/SixteenSegDisplay';
import HexDisplay from './modules/HexDisplay';
import OrGate from './modules/OrGate';
import Stepper from './modules/Stepper';
import NotGate from './modules/NotGate';
import ForceGate from './modules/ForceGate';
import Text from './modules/Text';
import TriState from './modules/TriState';
import Buffer from './modules/Buffer';
import ControlledInverter from './modules/ControlledInverter';
import Adder from './modules/Adder';
import TwoComplement from './modules/TwoComplement';
import Rom from './modules/Rom';
import Splitter from './modules/Splitter';
import Ground from './modules/Ground';
import Power from './modules/Power';
import Input from './modules/Input';
import Output from './modules/Output';
import BitSelector from './modules/BitSelector';
import ConstantVal from './modules/ConstantVal';
import NorGate from './modules/NorGate';
import DigitalLed from './modules/DigitalLed';
import VariableLed from './modules/VariableLed';
import Button from './modules/Button';
import RGBLed from './modules/RGBLed';
import SquareRGBLed from './modules/SquareRGBLed';
import Demultiplexer from './modules/Demultiplexer';
import Decoder from './modules/Decoder';
import Flag from './modules/Flag';
import MSB from './modules/MSB';
import LSB from './modules/LSB';
import PriorityEncoder from './modules/PriorityEncoder';
import Tunnel from './modules/Tunnel';
import ALU from './modules/ALU';
import Rectangle from './modules/Rectangle';
import Arrow from './modules/Arrow';

export function changeInputSize(size) {
    if (size == undefined || size < 2 || size > 10) return;
    if (this.inputSize == size) return;
    size = parseInt(size, 10);
    console.log(this.objectType, size);
    var obj = new window[this.objectType](this.x, this.y, this.scope, this.direction, size, this.bitWidth);
    simulationArea.lastSelected = obj;
    this.delete();
    console.log('obj', obj);
    return obj;
    // showProperties(obj);
}
export function getNextPosition(x = 0, scope = globalScope) {
    let possibleY = 20;
    const done = {};
    for (let i = 0; i < scope.Input.length - 1; i++) {
        if (scope.Input[i].layoutProperties.x === x) { done[scope.Input[i].layoutProperties.y] = 1; }
    }
    for (let i = 0; i < scope.Output.length; i++) {
        if (scope.Output[i].layoutProperties.x === x) { done[scope.Output[i].layoutProperties.y] = 1; }
    }
    while (done[possibleY] || done[possibleY + 10] || done[possibleY - 10]) { possibleY += 10; }
    const height = possibleY + 20;
    if (height > scope.layout.height) {
        const oldHeight = scope.layout.height;
        scope.layout.height = height;
        for (let i = 0; i < scope.Input.length; i++) {
            if (scope.Input[i].layoutProperties.y === oldHeight) { scope.Input[i].layoutProperties.y = scope.layout.height; }
        }
        for (let i = 0; i < scope.Output.length; i++) {
            if (scope.Output[i].layoutProperties.y === oldHeight) { scope.Output[i].layoutProperties.y = scope.layout.height; }
        }
    }
    return possibleY;
}

export const moduleProperty = { changeInputSize };

const modules = {
    AndGate,
    NandGate,
    Multiplexer,
    XorGate,
    XnorGate,
    SevenSegDisplay,
    SixteenSegDisplay,
    HexDisplay,
    OrGate,
    Stepper,
    NotGate,
    ForceGate,
    Text,
    TriState,
    Buffer,
    ControlledInverter,
    Adder,
    TwoComplement,
    Rom,
    Splitter,
    Ground,
    Power,
    Input,
    Output,
    BitSelector,
    ConstantVal,
    NorGate,
    DigitalLed,
    VariableLed,
    Button,
    RGBLed,
    SquareRGBLed,
    Demultiplexer,
    Decoder,
    Flag,
    MSB,
    LSB,
    PriorityEncoder,
    Tunnel,
    ALU,
    Rectangle,
    Arrow,
};
export default modules;
