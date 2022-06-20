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

<script>
import NavbarLink from './NavbarLink/NavbarLink.vue'

export default {
    name: 'NavbarLinks',
    components: {
        NavbarLink,
    },
    props: {
        navbarData: Array,
    },
}
</script>

<style scoped>
/* @import url('./NavbarLinks.css'); */
</style>
