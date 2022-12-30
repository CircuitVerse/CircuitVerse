<template>
    <li class="dropdown nav-dropdown">
        <a
            href="#"
            class=""
            data-toggle="dropdown"
            role="button"
            aria-haspopup="true"
            aria-expanded="false"
        >
            {{ $t('simulator.nav.' + navbarItem.text + '.heading') }}
            <span></span>
        </a>

        <DropDown
            :list-items="navbarItem.dropdownItems"
            :drop-down-header="navbarItem.text"
            drop-down-type="navLink"
        />
    </li>
</template>

<script lang="ts" setup>
import DropDown from '@/Dropdown/DropDown.vue'

const props = defineProps({
    navbarItem: { type: Object, default: () => {} },
})
</script>

<style scoped>
/* @import url("./NavbarLink.css"); */
</style>
