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

    <div v-for="(value, name) in obj.mutableProperties" :key="name">
        <InputGroups
            v-if="value.type === 'number'"
            :property-name="value.name"
            :property-value="obj[name]"
            property-value-type="number"
            :value-min="value.min || '0'"
            :value-max="value.max || '200'"
            :property-input-name="value.func"
            :property-input-id="value.name"
        />
        <p v-if="value.type === 'text'">
            <span>{{ value.name }}:</span>
            <input
                class="objectPropertyAttribute"
                type="text"
                :name="value.func"
                autocomplete="off"
                :maxlength="value.maxlength || '200'"
                :value="obj[name]"
            />
        </p>
        <p v-if="value.type === 'button'" class="btn-parent">
            <button
                class="objectPropertyAttribute btn custom-btn--secondary"
                type="button"
                :name="value.func"
            >
                {{ value.name }}
            </button>
        </p>
        <p v-if="value.type === 'textarea'">
            <span>{{ value.name }}</span>
            <textarea
                class="objectPropertyAttribute"
                type="text"
                autocomplete="off"
                rows="9"
                :name="value.func"
            >
                {{ obj[name] }}
            </textarea>
        </p>
    </div>
</template>

<script lang="ts" setup>
import { escapeHtml } from '#/simulator/src/utils'
import InputGroups from '#/components/Panels/Shared/InputGroups.vue'
import DropdownSelect from '#/components/Panels/Shared/DropdownSelect.vue'
const props = defineProps({
    obj: { type: Object, default: undefined },
})
const labelDirections = ['RIGHT', 'DOWN', 'LEFT', 'UP']
</script>
