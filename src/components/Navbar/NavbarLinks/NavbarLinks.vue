<template>
    <ul
        v-for="navbarItem in navbarData"
        id="toolbar"
        :key="navbarItem.id"
        class="navbar-nav navbar-menu noSelect pointerCursor"
    >
        <NavbarLink2 :navbar-item="navbarItem" />
    </ul>
</template>

<script lang="ts" setup>
import NavbarLink2 from './NavbarLink/NavbarLink2.vue';

const props = defineProps({
    navbarData: { type: Array, default: () => [] },
})
</script>

<style scoped>
/* @import url('./NavbarLinks.css'); */
</style>
