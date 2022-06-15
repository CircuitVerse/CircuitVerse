<template>
    <nav class="navbar navbar-expand-lg navbar-dark header">
        <Logo :cvlogo="navbarLogo" />
        <Hamburger v-if="showSidebar()" />

        <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
            <NavbarLinks :navbarData="navbarData" />

            <span
                class="projectName noSelect defaultCursor font-weight-bold"
                id="projectName"
            >
                Untitled
            </span>

            <QuickButton />

            <User
                :isUserSignedIn="isUserSignedIn"
                :userData="userDropdownItems"
            />
        </div>
    </nav>
</template>

<script>
import QuickButton from "./QuickButton/QuickButton.vue";
import User from "./User/User.vue";
import NavbarLinks from "./NavbarLinks/NavbarLinks.vue";

import navbarData from "./NavbarData.json";
import userDropdownItems from "./UserData.json";

import Logo from "../Logo/Logo.vue";
import Hamburger from "./Hamburger/Hamburger.vue";

export default {
    name: "Navbar",
    components: {
        Logo,
        Hamburger,
        QuickButton,
        User,
        NavbarLinks,
    },
    data() {
        return {
            navbarLogo: "logo",
            minWidthToShowSidebar: 992,
            navbarData: navbarData,
            userDropdownItems: userDropdownItems,
            isUserSignedIn: true,
        };
    },
    methods: {
        showSidebar() {
            return window.innerWidth < this.minWidthToShowSidebar
                ? true
                : false;
        },
    },
};
</script>

<style scoped>
@import "./Navbar.css";
</style>
