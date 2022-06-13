<template>
    <v-layout>
        <v-app-bar color="grey-lighten-2">
            <h2 class="text-center">{{ title }}</h2>
        </v-app-bar>
    </v-layout>
</template>

<script lang="ts" setup>
import { SimulatorStore } from "../store/SimulatorStore/SimulatorStore";

const store = SimulatorStore();
let { title } = store;
title = store.getTitle;
store.showTitle();
</script>
