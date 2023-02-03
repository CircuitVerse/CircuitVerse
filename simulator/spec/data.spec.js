/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import gatesCircuitData from './circuits/gates-circuitdata.json';
import decoderCircuitData from './circuits/Decoders-plexers-circuitdata.json';
import { checkIfBackup, scheduleBackup } from '../src/data/backupCircuit';
import undo from '../src/data/undo';
import redo from '../src/data/redo';
import save from '../src/data/save';
import {
    clearProject,
    newProject,
    recoverProject,
    saveOffline,
    openOffline,
} from '../src/data/project';
import createSaveAsImgPrompt from '../src/data/saveImage';

jest.mock('codemirror');

describe('Data dir Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    window.confirm = jest.fn(() => true);
    setup();

    test('load gates_circuitData without throwing error', () => {
        expect(() => load(gatesCircuitData)).not.toThrow();
    });

    test('should load another circuit data decoder_circuitData', () => {
        expect(() => load(decoderCircuitData)).not.toThrow();
    });

    test('schedule backup working', () => {
        // toggle states of inputs a dn then run schedule backup
        globalScope.Input.forEach((input) => {
            input.state = input.state === 1 ? 0 : 1;
            expect(() => scheduleBackup()).not.toThrow();
        });
    });

    test('check if backup performed', () => {
        expect(() => checkIfBackup(globalScope)).toBeTruthy();
    });

    test('undo working', () => {
        const beforeUndo = {
            backups: globalScope.backups.length,
            history: globalScope.history.length,
        };
        for (let i = 1; i < beforeUndo.backups; i++) {
            undo();
            const afterUndo = {
                backups: globalScope.backups.length + i,
                history: globalScope.history.length - i,
            };
            expect(afterUndo).toEqual(beforeUndo);
        }
    });

    test('redo working', () => {
        const beforeRedo = {
            backups: globalScope.backups.length,
            history: globalScope.history.length,
        };
        for (let i = 1; i < beforeRedo.history; i++) {
            redo();
            const afterRedo = {
                backups: globalScope.backups.length - i,
                history: globalScope.history.length + i,
            };
            expect(afterRedo).toEqual(beforeRedo);
        }
    });

    test('save updated circuit_data', () => {
        // save project
        window.__logix_project_id = decoderCircuitData.projectId;
        expect(() => save()).not.toThrow();
    });

    test('project working', () => {
        // create new project
        expect(() => newProject(true)).not.toThrow();
    });

    test('clear Project working', () => {
        // clear project
        expect(() => clearProject()).not.toThrow();
    });

    test('recover Project working', () => {
        // recover project from localstorage
        localStorage.setItem('recover', JSON.stringify(gatesCircuitData));
        expect(() => recoverProject()).not.toThrow();
    });

    test('SaveOffline working', () => {
        // save offline gate project
        expect(() => saveOffline()).not.toThrow();
    });

    test('OpenOffline working', () => {
        // open dialog
        openOffline();
        // click on first input
        $('#openProjectDialog input')[0].click();
        // click on open button
        $('#Open_offline_btn')[0].click();
        // it should load the offline saved project
        expect(globalScope.id).toBe(11597572508);
    });

    test('saveImage working', () => {
        expect(() => createSaveAsImgPrompt()).not.toThrow();
    });
});
