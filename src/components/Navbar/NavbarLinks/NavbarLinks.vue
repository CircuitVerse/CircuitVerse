<template>
    <ul class="navbar-nav navbar-menu noSelect pointerCursor" id="toolbar" :key="navbarItem.id" v-for="navbarItem in navbarData">
        <NavbarLink :navbarItem="navbarItem" />
    </ul>
</template>

<script>
import NavbarLink from './NavbarLink/NavbarLink.vue';

export default {
    name: 'NavbarLinks',
    props: {
        navbarData: Array,
    },
    components: {
        NavbarLink
    },
}
</script>

<style scoped>
/* @import url('./NavbarLinks.css'); */
</style>