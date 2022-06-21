/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import { runAll } from '../src/testbench';
import { createCombinationalAnalysisPrompt } from '../src/combinationalAnalysis';

jest.mock('codemirror');
describe('Combinational Analysis Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();

    test('createCombinationalAnalysisPrompt working', () => {
        expect(() => createCombinationalAnalysisPrompt()).not.toThrow();
    });

    test('Boolean Expression working', () => {
        $('#booleanExpression').val('AB');
        expect(() => $('#combinationAnalysisNextBtn').click()).not.toThrow();
    });

    test('Generate Circuit working', () => {
        expect(() => $('#combinationalAnalysisGenerateBtn').click()).not.toThrow();
    });

    test('testing Combinational circuit', () => {
        const testdata = {
            "type": "comb",
            "title": "combinationalAnalysis",
            "groups": [
              {
                "label": "testgroup",
                "inputs": [
                  {
                    "label": "A",
                    "bitWidth": 1,
                    "values": [ "0", "0", "1", "1" ]
                  },
                  {
                    "label": "B",
                    "bitWidth": 1,
                    "values": [ "0", "1", "0", "1"]
                  }
                ],
                "outputs": [
                  {
                    "label": "AB",
                    "bitWidth": 1,
                    "values": [ "0", "0", "0", "1"]
                  }
                ],
                "n": 4
              }
            ]
        };

        const result = runAll(testdata);
        expect(result.summary.passed).toBe(4);
    });
});
