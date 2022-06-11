<template>
    <h2 class="text-center">{{ text }}</h2>
</template>

<script lang="ts" setup>
import { HomeStore } from "../store/Home";

const main = HomeStore();
const { text } = main;
</script>
