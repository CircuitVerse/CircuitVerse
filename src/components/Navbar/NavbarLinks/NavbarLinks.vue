<template>
    <ul
        v-for="navbarItem in navbarData"
        id="toolbar"
        :key="navbarItem.id"
        class="navbar-nav navbar-menu noSelect pointerCursor"
    >
        <NavbarLink :navbar-item="navbarItem" />
    </ul>
</template>

<script lang="ts" setup>
import NavbarLink from '@/Navbar/NavbarLinks/NavbarLink/NavbarLink.vue'

const props = defineProps({
    navbarData: { type: Array, default: () => [] },
})
</script>

<style scoped>
/* @import url('./NavbarLinks.css'); */
</style>
