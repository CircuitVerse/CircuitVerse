import modules from './modules';
import Adder from './modules/Adder';
import ALU from './modules/ALU';
import AndGate from './modules/AndGate';
import Arrow from './modules/Arrow';
import ImageAnnotation from './modules/ImageAnnotation';
import BitSelector from './modules/BitSelector';
import Buffer from './modules/Buffer';
import Button from './modules/Button';
import ConstantVal from './modules/ConstantVal';
import ControlledInverter from './modules/ControlledInverter';
import Counter from './modules/Counter';
import Decoder from './modules/Decoder';
import Demultiplexer from './modules/Demultiplexer';
import DigitalLed from './modules/DigitalLed';
import Flag from './modules/Flag';
import Ground from './modules/Ground';
import HexDisplay from './modules/HexDisplay';
import Input from './modules/Input';
import LSB from './modules/LSB';
import MSB from './modules/MSB';
import Multiplexer from './modules/Multiplexer';
import NandGate from './modules/NandGate';
import NorGate from './modules/NorGate';
import NotGate from './modules/NotGate';
import OrGate from './modules/OrGate';
import Output from './modules/Output';
import Power from './modules/Power';
import PriorityEncoder from './modules/PriorityEncoder';
import Random from './modules/Random';
import Rectangle from './modules/Rectangle';
import RGBLed from './modules/RGBLed';
import RGBLedMatrix from './modules/RGBLedMatrix';
import SevenSegDisplay from './modules/SevenSegDisplay';
import SixteenSegDisplay from './modules/SixteenSegDisplay';
import Splitter from './modules/Splitter';
import SquareRGBLed from './modules/SquareRGBLed';
import Stepper from './modules/Stepper';
import Text from './modules/Text';
import TriState from './modules/TriState';
import Tunnel from './modules/Tunnel';
import TwoComplement from './modules/TwoComplement';
import VariableLed from './modules/VariableLed';
import XnorGate from './modules/XnorGate';
import XorGate from './modules/XorGate';
import Clock from './sequential/Clock';
import DflipFlop from './sequential/DflipFlop';
import Dlatch from './sequential/Dlatch';
import EEPROM from './sequential/EEPROM';
import JKflipFlop from './sequential/JKflipFlop';
import Keyboard from './sequential/Keyboard';
import RAM from './sequential/RAM';
import Rom from './sequential/Rom';
import SRflipFlop from './sequential/SRflipFlop';
import TflipFlop from './sequential/TflipFlop';
import TTY from './sequential/TTY';
import ForceGate from './testbench/ForceGate';
import TB_Input from './testbench/testbenchInput';
import TB_Output from './testbench/testbenchOutput';
import verilogMultiplier from './modules/verilogMultiplier';
import verilogDivider from './modules/verilogDivider';
import verilogPower from './modules/verilogPower';
import verilogShiftLeft from './modules/verilogShiftLeft';
import verilogShiftRight from './modules/verilogShiftRight';
import verilogRAM from './sequential/verilogRAM';

export default function setupModules() {
    var moduleSet = {
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
        verilogMultiplier,
        verilogDivider,
        verilogPower,
        verilogShiftLeft,
        verilogShiftRight,
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
        ImageAnnotation,
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
        verilogRAM,
        TB_Input,
        TB_Output,
        ForceGate,
    };
    Object.assign(modules, moduleSet);
}
