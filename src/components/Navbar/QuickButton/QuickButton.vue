<template>
    <div class="quick-btn" @ondragover="dragover">
        <div id="dragQPanel" class="panel-drag">
            <!-- <DragSvgDots /> -->
            <div class="drag-dot-svg"></div>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-save-online"
                title="Save Online"
                @click="saveOnline"
            ></button>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-save"
                title="Save Offline"
                @click="saveOffline"
            ></button>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-delete"
                title="Delete Selected"
                @click="deleteSelectedItem"
            ></button>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-download"
                title="Download as Image"
                @click="createSaveAsImgPrompt"
            ></button>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-zoom-fit"
                title="Fit to Screen"
                @click="zoomToFit"
            ></button>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-undo"
                title="Undo"
                @click="undoit"
            ></button>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-redo"
                title="Redo"
                @click="redoit"
            ></button>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-view"
                title="Preview Circuit"
                @click="view"
            >
                <i style="color: #ddd" class="fas fa-expand-arrows-alt"></i>
            </button>
        </div>
        <div class="zoom-slider">
            <button class="zoom-slider-decrement" @click="decrement">-</button>
            <input
                id="customRange1"
                type="range"
                class="custom-range"
                min="0"
                max="45"
                step="1"
            />
            <span id="slider_value"></span>
            <button class="zoom-slider-increment" @click="increment">+</button>
        </div>
    </div>
    <div id="exitView"></div>
</template>

<script lang="ts" setup>
import DragSvgDots from './DragSvgDots/DragSvgDots.vue'
import { deleteSelected } from '#/simulator/src/ux'
import undo from '#/simulator/src/data/undo'
import redo from '#/simulator/src/data/redo'
import { fullView } from '#/simulator/src/ux'
import { ZoomIn, ZoomOut } from '#/simulator/src/listeners'
import logixFunction from '#/simulator/src/data'

function dragover(): void {
    const quickBtn: HTMLElement | null = document.querySelector('.quick-btn')
    if (quickBtn) {
        quickBtn.style.boxShadow = 'none'
        quickBtn.style.background = 'var(--bg-navbar)'
    }
}

function saveOnline(): void {
    logixFunction.save()
}
function saveOffline(): void {
    logixFunction.saveOffline()
}
function deleteSelectedItem(): void {
    deleteSelected()
}
function createSaveAsImgPrompt(): void {
    logixFunction.createSaveAsImgPrompt()
}
function zoomToFit(): void {
    globalScope.centerFocus(false)
}
function undoit(): void {
    undo()
}
function redoit(): void {
    redo()
}
function view(): void {
    fullView()
}
function decrement(): void {
    ZoomOut()
}
function increment(): void {
    ZoomIn()
}
</script>

<style scoped>
/* @import url('./QuickButton.css'); */

.panel-drag {
    cursor: move;
    opacity: 0.6;
    /* display: grid;
  grid-template-columns: 1fr 1fr;
  grid-template-rows: 1fr 1fr 1fr 1fr 1fr 1fr;
  padding: 6px 0;
  width: 1px; */
}
.quick-btn {
    background: var(--bg-navbar);
    border-top: 1.5px solid var(--qp-br-tl);
    border-left: 1.5px solid var(--qp-br-tl);
    border-right: 1.5px solid var(--qp-br-rd);
    border-bottom: 1.5px solid var(--qp-br-rd);
}

.quick-btn {
    display: flex;
    position: absolute;
    width: 400px;
    height: 33px;
    top: 90px;
    right: 280px;
    border-radius: 7px;
    z-index: 100;
}

.quick-btn > div {
    margin: auto;
}

.quick-btn > div > button {
    margin: auto;
    border: none;
}

.drag-dot-svg {
    width: 12px;
    height: 20px;
    background: url(../../../styles/css/assets/shorcuts/dragDots.svg)
        center/contain;
    display: block;
    margin-left: 4px;
}

.quick-btn-save-online {
    background: url(../../../styles/css/assets/shorcuts/save-online.svg)
        center/cover;
    width: 21.43px;
    height: 15.2px;
    display: block;
}

.quick-btn-save {
    background: url(../../../styles/css/assets/shorcuts/save.svg) center/cover;
    width: 15.2px;
    height: 15.2px;
    display: block;
}

.quick-btn-delete {
    background: url(../../../styles/css/assets/shorcuts/delete.svg) center/cover;
    width: 20px;
    height: 15.2px;
    display: block;
}

.quick-btn-download {
    background: url(../../../styles/css/assets/shorcuts/download.svg)
        center/cover;
    width: 15.2px;
    height: 15.2px;
    display: block;
}

.quick-btn-zoom-fit {
    background: url(../../../styles/css/assets/shorcuts/fit.svg) center/cover;
    width: 15.2px;
    height: 15.2px;
    display: block;
}

.quick-btn-undo {
    background: url(../../../styles/css/assets/shorcuts/undo.svg) center/cover;
    width: 15.2px;
    height: 16.2px;
    display: block;
}

.quick-btn-redo {
    background: url(../../../styles/css/assets/shorcuts/redo.svg) center/cover;
    width: 15.2px;
    height: 16.2px;
    display: block;
}

.quick-btn-view {
    color: white;
}

.zoom-slider {
    color: white;
    font-size: 20px;
    padding-top: 0.2rem;
}

.zoom-slider-decrement {
    position: relative;
    padding-right: 4px;
    bottom: 0.3rem;
}
.zoom-slider-increment {
    position: relative;
    padding-left: 4px;
    bottom: 0.3rem;
}

.custom-range {
    width: 80px !important;
}
.custom-range::-moz-range-track {
    height: 1px;
}

.custom-range::-moz-range-thumb {
    width: 10px;
    height: 10px;
    background-color: white;
    border: 0;
    border-radius: 50%;
    cursor: pointer;
}
.custom-range:focus::-moz-range-thumb {
    box-shadow: 0 0 0 1px #fff, 0 0 0 0.2rem rgba(75, 86, 99, 0.25);
}

input[type='range'] {
    -webkit-appearance: none;
}

input[type='range']::-webkit-slider-runnable-track {
    height: 1px;
}

input[type='range']::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 10px;
    height: 10px;
    background-color: white;
    border: 0;
    border-radius: 50%;
    cursor: pointer;
}
</style>
