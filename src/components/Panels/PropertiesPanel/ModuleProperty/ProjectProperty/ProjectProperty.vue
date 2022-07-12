<template>
    <p>
        <span>Project:</span>
        <input
            id="projname"
            class="objectPropertyAttribute"
            type="text"
            autocomplete="off"
            name="setProjectName"
            :value="getProjectName() || 'Untitled'"
        />
    </p>

    <p>
        <span>Circuit:</span>
        <input
            id="circname"
            class="objectPropertyAttribute"
            type="text"
            autocomplete="off"
            name="changeCircuitName"
            :value="'Untitled' || globalScope.name"
        />
    </p>

    <InputGroups
        property-name="Clock Time (ms):"
        :property-value="simulationArea.timePeriod"
        property-value-type="number"
        value-min="50"
        step-size="10"
        property-input-name="changeClockTime"
        property-input-id="clockTime"
    />

    <p>
        <span>Clock Enabled:</span>
        <label class="switch">
            <input
                type="checkbox"
                class="objectPropertyAttributeChecked"
                name="changeClockEnable" />
            <span class="slider"></span
        ></label>
    </p>

    <p>
        <span>Lite Mode:</span>
        <label class="switch">
            <input
                type="checkbox"
                class="objectPropertyAttributeChecked"
                name="changeLightMode"
            />
            <span class="slider"></span>
        </label>
    </p>

    <p>
        <button
            type="button"
            class="panelButton btn btn-xs custom-btn--primary"
            @click="toggleLayoutMode"
        >
            Edit Layout
        </button>
        <button
            type="button"
            class="panelButton btn btn-xs custom-btn--tertiary"
            @click="deleteCurrentCircuit"
        >
            Delete Circuit
        </button>
    </p>
</template>

<script lang="ts" setup>
import { deleteCurrentCircuit } from '#/simulator/src/circuit'
import { getProjectName } from '#/simulator/src/data/save'
import { toggleLayoutMode } from '#/simulator/src/layoutMode'
import simulationArea from '#/simulator/src/simulationArea'
import InputGroups from '#/components/Panels/Shared/InputGroups.vue'
</script>

<style scoped>
.panelButton {
    width: 100%;
    margin-bottom: 5px;
}
</style>
