<template>
    <li class="dropdown nav-dropdown">
        <a
            href="#"
            class=""
            data-toggle="dropdown"
            role="button"
            aria-haspopup="true"
            aria-expanded="false"
            >{{ navbarItem.text }}<span></span>
        </a>

        <DropDown
            :listItems="navbarItem.dropdownItems"
            dropDownType="navLink"
        />
    </li>
</template>

<script>
import DropDown from "../../../Dropdown/DropDown.vue";

export default {
    name: "NavbarLink",
    props: {
        navbarItem: Object,
    },
    components: {
        DropDown,
    },
};
</script>

<style scoped>
/* @import url("./NavbarLink.css"); */
</style>
