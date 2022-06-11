<template>
    <v-layout>
        <v-app-bar color="grey-lighten-2">
            <h2 class="text-center">{{ title }}</h2>
        </v-app-bar>
    </v-layout>
</template>

<script lang="ts" setup>
    import { SimulatorStore } from '../store/Simulator'
    const main = SimulatorStore();
    const { title } = main
</script>
