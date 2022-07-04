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
    <p v-if="!obj.labelDirectionFixed">
        <span>Label Direction:</span>
        <select
            class="objectPropertyAttribute"
            name="newLabelDirection"
            :value="obj.labelDirection"
        >
            <option
                v-for="direction in labelDirections"
                :key="direction"
                :value="direction"
            >
                {{ direction }}
            </option>
        </select>
    </p>
    <p v-if="!obj.directionFixed">
        <span>Direction:</span>
        <select
            class="objectPropertyAttribute"
            name="newDirection"
            :value="obj.direction"
        >
            <option
                v-for="direction in labelDirections"
                :key="direction"
                :value="direction"
            >
                {{ direction }}
            </option>
        </select>
    </p>
    <p v-if="!obj.orientationFixed">
        <span>Orientation:</span>
        <select
            class="objectPropertyAttribute"
            name="newDirection"
            :value="obj.direction"
        >
            <option
                v-for="direction in labelDirections"
                :key="direction"
                :value="direction"
            >
                {{ direction }}
            </option>
        </select>
    </p>
</template>

<script lang="ts" setup>
import { escapeHtml } from '#/simulator/src/utils'
import { ref } from '@vue/reactivity'
import InputGroups from '../../Shared/InputGroups.vue'
const props = defineProps({
    data: { type: Object, default: undefined },
})
const obj = props.data
const labelDirections = ref(['RIGHT', 'DOWN', 'LEFT', 'UP'])
</script>

<!-- 
is there any difference between 
directionFixed
orientationFixed
code (s) in ux.js except the span 
-->
