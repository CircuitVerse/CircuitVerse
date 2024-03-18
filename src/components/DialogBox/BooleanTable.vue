<template>
    <table class="content-table">
        <tbody style="display: block; max-height: 70vh;">
            <tr>
                <th v-for="tableHeading in tableHeader" :key="tableHeading">
                    {{ tableHeading }}
                </th>
            </tr>
            <tr v-for="tableRow in tableBody" :key="tableRow">
                <th v-for="tableElement in tableRow" :key="tableElement">
                    {{ tableElement }}
                </th>
            </tr>
        </tbody>
    </table>
</template>

<script lang="ts" setup>
const props = defineProps({
    tableHeader: { type: Array, default: () => [] },
    tableBody: { type: Array, default: () => [] },
})
</script>
