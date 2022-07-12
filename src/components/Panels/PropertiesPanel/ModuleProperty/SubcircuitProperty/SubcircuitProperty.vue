<template>
    <div v-if="obj.canShowInSubcircuit">
        <div
            v-for="(value, name) in obj.subcircuitMutableProperties"
            :key="name"
        >
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
            <p v-if="value.type === 'checkbox'">
                <span>value.name </span>
                <label class="switch">
                    <input
                        type="checkbox"
                        class="objectPropertyAttributeChecked"
                        :name="value.func"
                    />
                    <span class="slider"></span>
                </label>
            </p>
        </div>
        <DropdownSelect
            v-if="
                obj.subcircuitMutableProperties &&
                !obj.labelDirectionFixed &&
                !obj.subcircuitMetadata.labelDirection
            "
            :dropdown-array="labelDirections"
            property-name="newLabelDirection"
            :property-value="
                obj.subcircuitMetadata.labelDirection || obj.labelDirection
            "
            property-input-name="Label Direction: "
            property-select-id="subcircuitLabelDirection"
        />
    </div>
</template>

<script lang="ts" setup>
const props = defineProps({
    obj: { type: Object, default: undefined },
})
const labelDirections = ['RIGHT', 'DOWN', 'LEFT', 'UP']
</script>
