<template>
    <div style="height: 100%; width: 100%">
        <div
            id="simulation"
            class="simulation"
            style="height: 100%; width: 100%"
        >
            <div
                class="noSelect pointerCursor"
                style="position: absolute; left: 0; top: 0; z-index: 4"
            >
                <TabsBar />
            </div>
            <div id="code-window" class="code-window-embed">
                <textarea id="codeTextArea"></textarea>
            </div>
            <!-- <% if @project&.assignment_id.present? && @project&.assignment.elements_restricted? %> -->
            <!-- <div id="restrictedElementsDiv" class="alert alert-danger">
                <div>
                    <span style="font-style: italic">
                        Restricted elements used:
                    </span>
                    <span id="restrictedElementsDiv--list"> </span>
                </div>
            </div> -->
            <!-- <% end %> -->
            <div id="MessageDiv"></div>

            <div
                id="canvasArea"
                class="canvasArea"
                style="height: 100%; width: 100%"
            >
                <canvas
                    id="backgroundArea"
                    style="position: absolute; left: 0; top: 0; z-index: 0"
                ></canvas>
                <canvas
                    id="simulationArea"
                    style="
                        position: absolute;
                        left: 0;
                        top: 0;
                        z-index: 1;
                        width: 100%;
                        height: 100%;
                    "
                ></canvas>
            </div>
            <div id="elementName"></div>
            <div id="zoom-in-out-embed" class="zoom-wrapper">
                <div class="noSelect">
                    <button
                        id="zoom-in-embed"
                        type="button"
                        style="font-size: 25px"
                        @click="zoomInEmbed"
                    >
                        <span
                            class="fa fa-search-plus"
                            aria-hidden="true"
                            title="Zoom In"
                        ></span>
                    </button>
                </div>
                <div class="noSelect">
                    <button
                        id="zoom-out-embed"
                        type="button"
                        style="font-size: 25px"
                        @click="zoomOutEmbed"
                    >
                        <span
                            class="fa fa-search-minus"
                            aria-hidden="true"
                            title="Zoom Out"
                        ></span>
                    </button>
                </div>
            </div>

            <div
                style="position: absolute; right: 10px; top: 25px; z-index: 100"
                class="clockPropertyHeader noSelect"
            >
                <div id="clockProperty">
                    <input
                        type="button"
                        class="objectPropertyAttributeEmbed custom-btn--secondary embed-fullscreen-btn"
                        name="toggleFullScreen"
                        value="Full Screen"
                        @click="toggleFullScreen"
                    />
                    <div>
                        Time:
                        <input
                            v-model="timePeriod"
                            class="objectPropertyAttributeEmbed embed-time-input"
                            min="50"
                            type="number"
                            style="width: 48px"
                            step="10"
                            name="changeClockTime"
                        />
                    </div>
                    <div>
                        Clock:
                        <label class="switch">
                            <input
                                v-model="clockEnabled"
                                type="checkbox"
                                class="objectPropertyAttributeEmbedChecked"
                                name="changeClockEnable"
                            />
                            <span class="slider"></span>
                        </label>
                    </div>
                </div>
            </div>
            <div
                class="sk-folding-cube loadingIcon"
                style="
                    display: inline-block;
                    position: absolute;
                    right: 50%;
                    bottom: 50%;
                    z-index: 100;
                "
            >
                <div class="sk-cube1 sk-cube"></div>
                <div class="sk-cube2 sk-cube"></div>
                <div class="sk-cube4 sk-cube"></div>
                <div class="sk-cube3 sk-cube"></div>
            </div>

            <!-- <% if @external_embed  == true %> -->
            <div id="bottom_right_circuit_heading">
                project Name
                <!-- <h5><%= @project.name %></h5> -->
            </div>
            <div id="bottom_right_watermark">
                <a
                    style="
                        text-decoration: none;
                        position: fixed;
                        bottom: 0px;
                        right: 25px;
                        padding: 8px;
                        font-family: Verdana;
                        font-size: 12px;
                        color: grey;
                        z-index: 2;
                    "
                    href="https://circuitverse.org/"
                    target="_blank"
                >
                    Made With CircuitVerse
                </a>
            </div>
            <!-- <% end %> -->
        </div>
    </div>
</template>

<script lang="ts" setup>
import { ref, onBeforeMount, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import simulationArea, { changeClockTime } from '#/simulator/src/simulationArea'
import {
    scheduleUpdate,
    updateCanvasSet,
    wireToBeCheckedSet,
    gridUpdateSet,
} from '#/simulator/src/engine'
import { prevPropertyObjSet, prevPropertyObjGet } from '#/simulator/src/ux'
import { circuitProperty, scopeList } from '#/simulator/src/circuit'
import { ZoomIn, ZoomOut } from '#/simulator/src/listeners'
import { setup } from '#/simulator/src/setup'
import startListeners from '#/simulator/src/embedListeners'
import TabsBar from '#/components/TabsBar/TabsBar.vue'
// import { time } from 'console'
// __logix_project_id = "<%= @logix_project_id %>";
// embed=true;
// <% if @project&.assignment_id.present? %>
// restrictedElements = JSON.parse('<%= raw @project&.assignment.clean_restricted_elements %>');
// <% else %>
// restrictedElements = [];
// <% end %>
const route = useRoute()
const timePeriod = ref(simulationArea.timePeriod)
const clockEnabled = ref(simulationArea.clockEnabled)

// watch(timePeriod, function (val) {
//     simulationArea.timePeriod = val
// })

watch(timePeriod, (val) => {
    scheduleUpdate()
    updateCanvasSet(true)
    wireToBeCheckedSet(1)
    if (
        simulationArea.lastSelected &&
        simulationArea.lastSelected['changeClockTime']
    ) {
        prevPropertyObjSet('changeClockTime') || prevPropertyObjGet()
    } else {
        if (val < 50) val = 50
        changeClockTime(val)
    }
})

watch(clockEnabled, (val) => {
    scheduleUpdate()
    updateCanvasSet(true)
    wireToBeCheckedSet(1)
    if (
        simulationArea.lastSelected &&
        simulationArea.lastSelected['changeClockEnable']
    ) {
        prevPropertyObjSet('changeClockEnable') || prevPropertyObjGet()
    } else {
        circuitProperty.changeClockEnable(val)
    }
})

onBeforeMount(() => {
    window.embed = true
    window.logixProjectId = route.params.projectId
})

onMounted(() => {
    // $('#zoom-in-embed').on('click', () => ZoomIn())
    // $('#zoom-out-embed').on('click', () => ZoomOut())

    startListeners()
    setup()
})

function zoomInEmbed() {
    ZoomIn()
}

function zoomOutEmbed() {
    ZoomOut()
}

// Center focus accordingly
function exitHandler() {
    setTimeout(() => {
        Object.keys(scopeList).forEach((id) => {
            scopeList[id].centerFocus(true)
        })
        gridUpdateSet(true)
        scheduleUpdate()
    }, 100)
}

function GoInFullscreen(element) {
    if (element.requestFullscreen) {
        element.requestFullscreen()
    } else if (element.mozRequestFullScreen) {
        element.mozRequestFullScreen()
    } else if (element.webkitRequestFullscreen) {
        element.webkitRequestFullscreen()
    } else if (element.msRequestFullscreen) {
        element.msRequestFullscreen()
    }
}

function GoOutFullscreen() {
    if (document.exitFullscreen) {
        document.exitFullscreen()
    } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen()
    } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen()
    } else if (document.msExitFullscreen) {
        document.msExitFullscreen()
    }
}

function getfullscreenelement() {
    return (
        document.fullscreenElement ||
        document.webkitFullscreenElement ||
        document.mozFullScreenElement ||
        document.msFullscreenElement
    )
}

function toggleFullScreen() {
    if (!getfullscreenelement()) {
        GoInFullscreen(document.documentElement)
    } else {
        GoOutFullscreen()
    }
}

// Full screen Listeners
if (document.addEventListener) {
    document.addEventListener('webkitfullscreenchange', exitHandler, false)
    document.addEventListener('mozfullscreenchange', exitHandler, false)
    document.addEventListener('fullscreenchange', exitHandler, false)
    document.addEventListener('MSFullscreenChange', exitHandler, false)
}
</script>

<style>
#app {
    height: 100%;
}

.embed-time-input {
    background-color: var(--bg-circuit);
    color: var(--text);
}
</style>
