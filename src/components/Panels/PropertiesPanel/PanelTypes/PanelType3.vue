<template>
    <p>
        <span>BitWidth:</span>
        <div class="input-group">
            <div class="input-group-prepend">
                <button 
                    style=" border:none; min-width: 2.5rem" 
                    class="btnDecrement" 
                    type="button"
                     @click="decreaseValue()"
                >
                    <strong>-</strong>
                </button>
            </div>
            <input
                id="number"
                style="text-align: center"
                class="objectPropertyAttribute form-control"
                type="number"
                name="newBitWidth"
                min="1"
                max="32"
                :value="obj.bitWidth"
            />
            <div class="input-group-append">
                <button 
                    style="border:none; min-width: 2.5rem" 
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
import simulationArea from '#/simulator/src/simulationArea'
import { checkPropertiesUpdate, objectPropertyAttributeUpdate } from '#/simulator/src/ux'

const props = defineProps({
    data: { type: Object, default: undefined },
})
const obj = props.data
// console.log(obj)
// console.log(simulationArea.lastSelected)

function increaseValue() {
    var value = parseInt(document.getElementById('number').value, 10);
    value = isNaN(value) ? 0 : value;
    value++;
    obj.bitWidth++;
    document.getElementById('number').value = value;
    // manually triggering on change event
    const e = new Event("change");
    const element = document.querySelector('.objectPropertyAttribute')
    element.dispatchEvent(e);
}

function decreaseValue() {
    var value = parseInt(document.getElementById('number').value, 10);
    value = isNaN(value) ? 0 : value;
    value < 1 ? value = 1 : '';
    value--;
    obj.bitWidth--;
    document.getElementById('number').value = value;
    // manually triggering on change event
    const e = new Event("change");
    const element = document.querySelector('.objectPropertyAttribute')
    element.dispatchEvent(e);
}

</script>
