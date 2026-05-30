/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import { bitConverterDialog, setBaseValues, setupBitConvertor } from '../src/utils';

jest.mock('codemirror');
describe('data dir working', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();

    // Open BitConvertor Dialog
    test('bitConvertor Dialog working', () => {
        expect(() => bitConverterDialog()).not.toThrow();
    });

    test('function setupBitConvertor working', () => {
        expect(() => setupBitConvertor()).not.toThrow();
    });

    test('function setBaseValues working', () => {
        const randomBaseValue = Math.floor(Math.random() * 100);
        console.log('Testing for Base Value --> ', randomBaseValue);
        expect(() => setBaseValues(randomBaseValue)).not.toThrow();
    });

    test('converting decimal number to octal, binary, bcd, hexadecimal', () => {
        const decValues = [{
            base: 10,
            expected: {
                bin: '0b1010',
                oct: '012',
                bcd: '10000',
                hex: '0xa',
            },
        }, {
            base: 21,
            expected: {
                bin: '0b10101',
                oct: '025',
                bcd: '100001',
                hex: '0x15',
            },
        }, {
            base: 34,
            expected: {
                bin: '0b100010',
                oct: '042',
                bcd: '110100',
                hex: '0x22',
            },
        }, {
            base: 56,
            expected: {
                bin: '0b111000',
                oct: '070',
                bcd: '1010110',
                hex: '0x38',
            },
        }, {
            base: 87,
            expected: {
                bin: '0b1010111',
                oct: '0127',
                bcd: '10000111',
                hex: '0x57',
            },
        }, {
            base: 999,
            expected: {
                bin: '0b1111100111',
                oct: '01747',
                bcd: '100110011001',
                hex: '0x3e7',
            },
        }];
        decValues.forEach((testCase) => {
            setBaseValues(testCase.base);
            expect($('#binaryInput').val()).toBe(testCase.expected.bin);
            expect($('#bcdInput').val()).toBe(testCase.expected.bcd);
            expect($('#octalInput').val()).toBe(testCase.expected.oct);
            expect($('#hexInput').val()).toBe(testCase.expected.hex);
        });
    });
});
