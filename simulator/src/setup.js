/* eslint-disable import/no-cycle */
/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import * as metadata from './metadata.json';
import { generateId, showMessage} from './utils';
import backgroundArea from './backgroundArea';
import plotArea from './plotArea';
import simulationArea from './simulationArea';
import { dots } from './canvasApi';
import { update, updateSimulationSet, updateCanvasSet } from './engine';
import { setupUI } from './ux';
import startMainListeners from './listeners';
import startEmbedListeners from './embedListeners';
import './embed';
import { newCircuit } from './circuit';
import load from './data/load';
import save from './data/save';
import showTourGuide from './tutorials';
import setupModules from './moduleSetup';
import 'codemirror/lib/codemirror.css';
import 'codemirror/addon/hint/show-hint.css';
import 'codemirror/mode/javascript/javascript.js'; // verilog.js from codemirror is not working because array prototype is changed.
import 'codemirror/addon/edit/closebrackets.js';
import 'codemirror/addon/hint/anyword-hint.js';
import 'codemirror/addon/hint/show-hint.js';
import {setupCodeMirrorEnvironment} from './Verilog2CV';
import { keyBinder } from './hotkey_binder/keyBinder';

// TODO include subset of bootstrap we use instead of whole framework
import 'bootstrap';

import 'jquery-ui/themes/base/core.css';
import 'jquery-ui/themes/base/resizable.css';
import 'jquery-ui/themes/base/accordion.css';
import 'jquery-ui/themes/base/dialog.css';
import 'jquery-ui/themes/base/tooltip.css';
import 'jquery-ui/themes/base/theme.css';

import autocomplete from 'jquery-ui/ui/widgets/resizable';
import accordion from 'jquery-ui/ui/widgets/accordion';
import dialog from 'jquery-ui/ui/widgets/dialog';
import tooltip from 'jquery-ui/ui/widgets/tooltip';
import sortable from 'jquery-ui/ui/widgets/sortable';

window.width = undefined;
window.height = undefined;
window.DPR = window.devicePixelRatio || 1; // devicePixelRatio, 2 for retina displays, 1 for low resolution displays

/**
 * to resize window and setup things it
 * sets up new width for the canvas variables.
 * Also redraws the grid.
 * @category setup
 */
export function resetup() {
    DPR = window.devicePixelRatio || 1;
    if (lightMode) { DPR = 1; }
    width = document.getElementById('simulationArea').clientWidth * DPR;
    if (!embed) {
        height = (document.body.clientHeight - document.getElementById('toolbar').clientHeight) * DPR;
    } else {
        height = (document.getElementById('simulation').clientHeight) * DPR;
    }
    // setup simulationArea and backgroundArea variables used to make changes to canvas.
    backgroundArea.setup();
    simulationArea.setup();
    // redraw grid
    dots();
    document.getElementById('backgroundArea').style.height = height / DPR + 100;
    document.getElementById('backgroundArea').style.width = width / DPR + 100;
    document.getElementById('canvasArea').style.height = height / DPR;
    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    backgroundArea.canvas.width = width + 100 * DPR;
    backgroundArea.canvas.height = height + 100 * DPR;
    if (!embed) {
        plotArea.setup();
    }
    updateCanvasSet(true);
    update(); // INEFFICIENT, needs to be deprecated
    simulationArea.prevScale = 0;
    dots();
}

window.onresize = resetup; // listener
window.onorientationchange = resetup; // listener

// for mobiles
window.addEventListener('orientationchange', resetup); // listener

/**
 * function to setup environment variables like projectId and DPR
 * @category setup
 */
function setupEnvironment() {
    setupModules();
    const projectId = generateId();
    window.projectId = projectId;
    updateSimulationSet(true);
    const DPR = window.devicePixelRatio || 1;
    newCircuit('Main');
    window.data = {};
    resetup();
    setupCodeMirrorEnvironment();
}

/**
 * It initializes some useful array which are helpful
 * while simulating, saving and loading project.
 * It also draws icons in the sidebar
 * @category setup
 */
function setupElementLists() {
    $('#menu').empty();

    window.circuitElementList = metadata.circuitElementList;
    window.annotationList = metadata.annotationList;
    window.inputList = metadata.inputList;
    window.subCircuitInputList = metadata.subCircuitInputList;
    window.moduleList = [...circuitElementList, ...annotationList];
    window.updateOrder = ['wires', ...circuitElementList, 'nodes', ...annotationList]; // Order of update
    window.renderOrder = [...(moduleList.slice().reverse()), 'wires', 'allNodes']; // Order of render


    function createIcon(element) {
        return `<div class="icon logixModules" id="${element}" title="${element}">
            <img src= "/img/${element}.svg" >
        </div>`;
    }

    window.elementHierarchy = metadata.elementHierarchy;
    window.elementPanelList = [];
    for (const category in elementHierarchy) {
        let htmlIcons = '';
        const categoryData = elementHierarchy[category];
        for (let i = 0; i < categoryData.length; i++) {
            const element = categoryData[i];
            if(!element.startsWith("verilog")) {
                htmlIcons += createIcon(element);
                window.elementPanelList.push(element);
            }
        }

        const accordionData = `<div class="panelHeader">${category}</div>
        <div class="panel customScroll">
        ${htmlIcons}
        </div>`;

        $('#menu').append(accordionData);
    }
}

/**
 * The first function to be called to setup the whole simulator
 * @category setup
 */
export function setup() {
    const startListeners = embed ? startEmbedListeners : startMainListeners;
    setupElementLists();
    setupEnvironment();
    if (!embed) { setupUI(); }
    startListeners();
    if (!embed) { keyBinder();}
    
    // Load project data after 1 second - needs to be improved, delay needs to be eliminated
    setTimeout(() => {
        if (__logix_project_id != 0) {
            $('.loadingIcon').fadeIn();
            $.ajax({
                url: `/simulator/get_data/${__logix_project_id}`,
                type: 'GET',
                success(response) {
                    var data = (response);
                    if (data) {
                        load(data);
                        simulationArea.changeClockTime(data.timePeriod || 500);
                    }
                    $('.loadingIcon').fadeOut();
                },
                failure() {
                    alert('Error: could not load ');
                    $('.loadingIcon').fadeOut();
                },
            });
        } else if (localStorage.getItem('recover_login') && userSignedIn) {
            // Restore unsaved data and save
            var data = JSON.parse(localStorage.getItem('recover_login'));
            load(data);
            localStorage.removeItem('recover');
            localStorage.removeItem('recover_login');
            save();
        } else if (localStorage.getItem('recover')) {
            // Restore unsaved data which didn't get saved due to error
            showMessage("We have detected that you did not save your last work. Don't worry we have recovered them. Access them using Project->Recover");
        }
    }, 1000);

    if (!localStorage.tutorials_tour_done && !embed) {
        setTimeout(()=> {showTourGuide();}, 2000);
    }
    
}
