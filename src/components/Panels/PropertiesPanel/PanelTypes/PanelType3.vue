<template>
    <InputGroups
        v-if="!obj.fixedBitWidth"
        property-name="BitWidth:"
        :property-value="obj.bitWidth"
        property-value-type="number"
        value-min="1"
        value-max="32"
        property-input-name="newBitWidth"
        property-input-id="bitWidth"
    />
    <InputGroups
        v-if="obj.changeInputSize"
        property-name="Input Size:"
        :property-value="obj.inputSize"
        property-value-type="number"
        value-min="2"
        value-max="10"
        property-input-name="changeInputSize"
        property-input-id="inputSize"
    />
    <InputGroups
        v-if="!obj.propagationDelayFixed"
        property-name="Delay:"
        :property-value="obj.propagationDelay"
        property-value-type="number"
        value-min="0"
        value-max="100000"
        property-input-name="changePropagationDelay"
        property-input-id="delayValue"
    />
    <p v-if="!obj.disableLabel">
        <span>Label:</span>
        <input
            class="objectPropertyAttribute"
            type="text"
            name="setLabel"
            autocomplete="off"
            :value="escapeHtml(obj.label)"
        />
    </p>
    <DropdownSelect
        v-if="!obj.labelDirectionFixed"
        :dropdown-array="labelDirections"
        property-name="newLabelDirection"
        :property-value="obj.labelDirection"
        property-input-name="Label Direction:"
        property-select-id="labelDirectionValue"
    />
    <DropdownSelect
        v-if="!obj.directionFixed"
        :dropdown-array="labelDirections"
        property-name="newDirection"
        :property-value="obj.direction"
        property-input-name="Direction:"
        property-select-id="directionValue"
    />
    <DropdownSelect
        v-if="!obj.orientationFixed"
        :dropdown-array="labelDirections"
        property-name="newDirection"
        :property-value="obj.direction"
        property-input-name="Orientation:"
        property-select-id="orientationValue"
    />
</template>

<script lang="ts" setup>
import { escapeHtml } from '#/simulator/src/utils'
import InputGroups from '../../Shared/InputGroups.vue'
import DropdownSelect from '../../Shared/DropdownSelect.vue'
const props = defineProps({
    data: { type: Object, default: undefined },
})
const obj = props.data
const labelDirections = ['RIGHT', 'DOWN', 'LEFT', 'UP']
</script>

<!-- 
is there any difference between 
directionFixed
orientationFixed
code (s) in ux.js except the span 
-->
