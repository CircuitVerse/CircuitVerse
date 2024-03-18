/* eslint-disable import/no-cycle */
/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */

import { Tooltip } from 'bootstrap'
import metadata from './metadata.json'
import { generateId, showMessage } from './utils'
import backgroundArea from './backgroundArea'
import plotArea from './plotArea'
import simulationArea from './simulationArea'
import { dots } from './canvasApi'
import { update, updateSimulationSet, updateCanvasSet } from './engine'
import { setupUI } from './ux'
import startMainListeners from './listeners'
// import startEmbedListeners from './embedListeners'
import './embed'
import { newCircuit, scopeList } from './circuit'
import load from './data/load'
import save from './data/save'
import { showTourGuide } from './tutorials'
import setupModules from './moduleSetup'
import 'codemirror/lib/codemirror.css'
import 'codemirror/addon/hint/show-hint.css'
import 'codemirror/mode/javascript/javascript' // verilog.js from codemirror is not working because array prototype is changed.
import 'codemirror/addon/edit/closebrackets'
import 'codemirror/addon/hint/anyword-hint'
import 'codemirror/addon/hint/show-hint'
import { setupCodeMirrorEnvironment } from './Verilog2CV'
// import { keyBinder } from '#/components/DialogBox/CustomShortcut.vue'
import '../vendor/jquery-ui.min.css'
import '../vendor/jquery-ui.min'
import { confirmSingleOption } from '#/components/helpers/confirmComponent/ConfirmComponent.vue'
import { getToken } from '#/pages/simulatorHandler.vue'

/**
 * to resize window and setup things it
 * sets up new width for the canvas variables.
 * Also redraws the grid.
 * @category setup
 */
export function resetup() {
    DPR = window.devicePixelRatio || 1
    if (lightMode) {
        DPR = 1
    }
    width = document.getElementById('simulationArea').clientWidth * DPR
    if (!embed) {
        height =
            (document.body.clientHeight -
                document.getElementById('toolbar').clientHeight) *
            DPR
    } else {
        height = document.getElementById('simulation').clientHeight * DPR
    }
    // setup simulationArea and backgroundArea variables used to make changes to canvas.
    backgroundArea.setup()
    simulationArea.setup()
    // redraw grid
    dots()
    document.getElementById('backgroundArea').style.height =
        height / DPR + 100 + 'px'
    document.getElementById('backgroundArea').style.width =
        width / DPR + 100 + 'px'
    document.getElementById('canvasArea').style.height = height / DPR + 'px'
    simulationArea.canvas.width = width
    simulationArea.canvas.height = height
    backgroundArea.canvas.width = width + 100 * DPR
    backgroundArea.canvas.height = height + 100 * DPR
    if (!embed) {
        plotArea.setup()
    }
    updateCanvasSet(true)
    update() // INEFFICIENT, needs to be deprecated
    simulationArea.prevScale = 0
    dots()
}

window.onresize = resetup // listener
window.onorientationchange = resetup // listener

// for mobiles
window.addEventListener('orientationchange', resetup) // listener

/**
 * function to setup environment variables like projectId and DPR
 * @category setup
 */
function setupEnvironment() {
    setupModules()
    const projectId = generateId()
    window.projectId = projectId
    updateSimulationSet(true)
    // const DPR = window.devicePixelRatio || 1 // unused variable
    newCircuit('Main')
    window.data = {}
    resetup()
    setupCodeMirrorEnvironment()
}

/**
 * It initializes some useful array which are helpful
 * while simulating, saving and loading project.
 * It also draws icons in the sidebar
 * @category setup
 */
function setupElementLists() {
    // $('#menu').empty()

    window.circuitElementList = metadata.circuitElementList
    window.annotationList = metadata.annotationList
    window.inputList = metadata.inputList
    window.subCircuitInputList = metadata.subCircuitInputList
    window.moduleList = [...circuitElementList, ...annotationList]
    window.updateOrder = [
        'wires',
        ...circuitElementList,
        'nodes',
        ...annotationList,
    ] // Order of update
    window.renderOrder = [...moduleList.slice().reverse(), 'wires', 'allNodes'] // Order of render
}

/**
 * Fetches project data from API and loads it into the simulator.
 * @param {number} projectId The ID of the project to fetch data for
 * @category setup
 */
async function fetchProjectData(projectId) {
    try {
        const response = await fetch(
            `/api/v1/projects/${projectId}/circuit_data`,
            {
                method: 'GET',
                headers: {
                    Accept: 'application/json',
                    Authorization: `Token ${getToken('cvt')}`,
                },
            }
        )
        if (response.ok) {
            const data = await response.json()
            await load(data)
            await simulationArea.changeClockTime(data.timePeriod || 500)
            $('.loadingIcon').fadeOut()
        } else {
            throw new Error('API call failed')
        }
    } catch (error) {
        console.error(error)
        confirmSingleOption('Error: Could not load.')
        $('.loadingIcon').fadeOut()
    }
}

/**
 * Load project data immediately when available.
 * Improvement to eliminate delay caused by setTimeout in previous implementation revert if issues arise.
 * @category setup
 */
async function loadProjectData() {
    window.logixProjectId = window.logixProjectId ?? 0
    if (window.logixProjectId !== 0) {
        $('.loadingIcon').fadeIn()
        await fetchProjectData(window.logixProjectId)
    } else if (localStorage.getItem('recover_login') && window.isUserLoggedIn) {
        // Restore unsaved data and save
        const data = JSON.parse(localStorage.getItem('recover_login'))
        await load(data)
        localStorage.removeItem('recover')
        localStorage.removeItem('recover_login')
        await save()
    } else if (localStorage.getItem('recover')) {
        // Restore unsaved data which didn't get saved due to error
        showMessage(
            "We have detected that you did not save your last work. Don't worry we have recovered them. Access them using Project->Recover"
        )
    }
}

/**
 * Show tour guide if it hasn't been completed yet.
 * The tour is shown after a delay of 2 seconds.
 * @category setup
 */
function showTour() {
    if (!localStorage.tutorials_tour_done && !embed) {
        setTimeout(() => {
            showTourGuide()
        }, 2000)
    }
}

/**
 * The first function to be called to setup the whole simulator.
 * This function sets up the simulator environment, the UI, the listeners,
 * loads the project data, and shows the tour guide.
 * @category setup
 */
export function setup() {
    // let embed = false
    // const startListeners = embed ? startEmbedListeners : startMainListeners
    setupElementLists()
    setupEnvironment()
    if (!embed) {
        setupUI()
        startMainListeners()
    }
    // startListeners()
    loadProjectData()
    showTour()
}
