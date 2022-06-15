<template>
    <Navbar />
    <ContextMenu />
    <Extra />
</template>

<script lang="ts">
import Navbar from "../components/Navbar/Navbar.vue";
import Extra from "../components/Extra.vue";
import ContextMenu from "../components/ContextMenu/ContextMenu.vue";

import { setup } from '../simulator/src/setup';

export default {
    name: "Simulator",
    components: {
        Navbar,
        Extra,
        ContextMenu,
    },
    mounted() {
        console.log("setting up");
        setup();
    },
};
</script>
