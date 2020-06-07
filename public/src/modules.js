/* eslint-disable import/no-cycle */
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
import Text from './modules/Text';
import TriState from './modules/TriState';
import Buffer from './modules/Buffer';
import ControlledInverter from './modules/ControlledInverter';
import Adder from './modules/Adder';
import TwoComplement from './modules/TwoComplement';
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
import Counter from './modules/Counter';
import Random from './modules/Random';
import RGBLedMatrix from './modules/RGBLedMatrix';
import simulationArea from './simulationArea';
import TflipFlop from './sequential/TflipFlop';
import DflipFlop from './sequential/DflipFlop';
import Dlatch from './sequential/Dlatch';
import SRflipFlop from './sequential/SRflipFlop';
import JKflipFlop from './sequential/JKflipFlop';
import TTY from './sequential/TTY';
import Keyboard from './sequential/Keyboard';
import Clock from './sequential/Clock';
import RAM from './sequential/RAM';
import EEPROM from './sequential/EEPROM';
import Rom from './sequential/Rom';
import TB_Input from './testbench/testbenchInput';
import TB_Output from './testbench/testbenchOutput';
import ForceGate from './testbench/ForceGate';

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

const modules = {
    AndGate,
    Random,
    NandGate,
    Counter,
    Multiplexer,
    XorGate,
    XnorGate,
    SevenSegDisplay,
    SixteenSegDisplay,
    HexDisplay,
    OrGate,
    Stepper,
    NotGate,
    Text,
    TriState,
    Buffer,
    ControlledInverter,
    Adder,
    TwoComplement,
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
    RGBLedMatrix,
    TflipFlop,
    DflipFlop,
    Dlatch,
    SRflipFlop,
    JKflipFlop,
    TTY,
    Keyboard,
    Clock,
    Rom,
    EEPROM,
    RAM,
    TB_Input,
    TB_Output,
    ForceGate,
};
export default modules;
export function changeInputSize(size) {
    if (size == undefined || size < 2 || size > 10) return;
    if (this.inputSize == size) return;
    size = parseInt(size, 10);
    const obj = new modules[this.objectType](this.x, this.y, this.scope, this.direction, size, this.bitWidth);
    this.delete();
    simulationArea.lastSelected = obj;
    return obj;
    // showProperties(obj);
}
