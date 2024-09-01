<template>
  <div class="quick-mobile">
    <div class="quick-btn-mobile">
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-save-online"
              title="Save Online"
              @click="saveOnline"
          ></button>
      </div>
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-save"
              title="Save Offline"
              @click="saveOffline"
          ></button>
      </div>
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-delete"
              title="Delete Selected"
              @click="deleteSelectedItem"
          ></button>
      </div>
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-download"
              title="Download as Image"
              @click="createSaveAsImgPrompt"
          ></button>
      </div>
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-zoom-fit"
              title="Fit to Screen"
              @click="zoomToFit"
          ></button>
      </div>
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-undo"
              title="Undo"
              @click="undoit"
          ></button>
      </div>
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-redo"
              title="Redo"
              @click="redoit"
          ></button>
      </div>
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-view"
              title="Preview Circuit"
              @click="view"
          >
          <i :style="{ color: '#ddd', transform: simulatorMobileStore.showMobileView ? 'scale(1)' : 'scale(1.25)' }" class="fas fa-expand-arrows-alt"></i>
          </button>
      </div>
      <div class="btn-container">
          <button
              type="button"
              class="quick-btn-timing"
              @mousedown="simulatorMobileStore.showTimingDiagram = !simulatorMobileStore.showTimingDiagram"
          >
          <i :style="{ transform: simulatorMobileStore.showMobileView ? 'scale(1)' : 'scale(1.25)' }" class="fa-solid fa-timeline"></i>
          </button>
    </div>
    <nav class="navbar mobile-nav navbar-expand-lg navbar-dark">
      <Hamburger2 v-if="simulatorMobileStore.showMobileView" :navbar-data="navbarData" />
    </nav>
    </div>
    <div class="slider-container">
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
  </div>
  <div id="exitView"></div>
</template>

<script lang="ts" setup>
import Hamburger2 from '../Hamburger/Hamburger2.vue'
import navbarData from '#/assets/constants/Navbar/NAVBAR_DATA.json'
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore'
import { saveOnline, saveOffline, deleteSelectedItem, createSaveAsImgPrompt, zoomToFit, undoit, redoit, view, decrement, increment } from './QuickButton';

const simulatorMobileStore = useSimulatorMobileStore()
</script>

<style scoped>
/* @import url('./QuickButton.css'); */

.mobile-nav {
  padding: 0 0 !important;
}

.slider-container {
  display: flex;
  justify-content: center;
}

.quick-btn-mobile {
  background: var(--bg-navbar);
  border-top: 1.5px solid var(--qp-br-tl);
  border-left: 1.5px solid var(--qp-br-tl);
  border-right: 1.5px solid var(--qp-br-rd);
  border-bottom: 1.5px solid var(--qp-br-rd);
}

.quick-btn-mobile {
  display: flex;
  align-items: center;
  z-index: 99;
  justify-content: space-between;
  padding: 0 1.5rem;
}

.quick-btn-mobile > div > button {
  border: none;
}

.quick-mobile {
  display: flex;
  flex-direction: column;
  background: var(--bg-navbar);
}

.btn-container {
  padding: 0.75rem 0;
}

.quick-btn-view, .quick-btn-timing {
  color: white;
}

.zoom-slider {
  display: flex;
  gap: 1rem;
  width: 90%;
}

.custom-range {
  width: 90% !important;
}

@media (max-width: 768px) {
  .quick-btn-mobile {
    padding: 0 0.75rem;
  }
}
</style>
