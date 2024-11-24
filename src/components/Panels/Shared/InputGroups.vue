<template>
    <p>
        <span>{{ propertyName }}</span>
        <div class="input-group">
            <div class="input-group-prepend">
                <button
                    style="border: none; min-width: 2.5rem"
                    class="btnDecrement"
                    type="button"
                    @click="decreaseValue()"
                >
                    <strong>-</strong>
                </button>
            </div>
            <input
                :id="propertyInputId"
                style="text-align: center"
                class="objectPropertyAttribute form-control"
                :type="propertyValueType"
                :name="propertyInputName"
                :min="valueMin"
                :max="valueMax"
                :value="propertyValue"
            />
            <div class="input-group-append">
                <button
                    style="border: none; min-width: 2.5rem"
                    class="btnIncrement"
                    type="button"
                    @click="increaseValue()"
                >
                    <strong>+</strong>
                </button>
            </div>
        </div>
    </p>
</template>

<script lang="ts" setup>
const props = defineProps({
    propertyName: { type: String, default: 'Property Name' },
    propertyValue: { type: Number, default: 0 },
    propertyValueType: { type: String, default: 'number' },
    valueMin: { type: String, default: '0' },
    valueMax: { type: String, default: '100000000000000' },
    stepSize: { type: String, default: '1' },
    propertyInputName: { type: String, default: 'Property_Input_Name' },
    propertyInputId: { type: String, default: 'Property_Input_Id' },
})

// can be modified if required
function increaseValue() {
    const ele = document.getElementById(props.propertyInputId)
    var value = parseInt(ele.value, 10)
    var step = parseInt(props.stepSize, 10)
    value = isNaN(value) ? 0 : value
    step = isNaN(step) ? 1 : step
    if (value + step <= props.valueMax) value = value + step
    else return
    props.propertyValue = value
    ele.value = value
    // manually triggering on change event
    const e = new Event('change')
    ele.dispatchEvent(e)
}

function decreaseValue() {
    const ele = document.getElementById(props.propertyInputId)
    var value = parseInt(ele.value, 10)
    var step = parseInt(props.stepSize, 10)
    value = isNaN(value) ? 0 : value
    step = isNaN(step) ? 1 : step
    if (value - step >= props.valueMin) value = value - step
    else return
    props.propertyValue = value
    ele.value = value
    // manually triggering on change event
    const e = new Event('change')
    ele.dispatchEvent(e)
}
</script>

<style scoped>
/* Hide spinners for numeric input' */

input[type="number"]::-webkit-inner-spin-button,
input[type="number"]::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

input[type=number]{
    -moz-appearance: textfield;
}
</style>
