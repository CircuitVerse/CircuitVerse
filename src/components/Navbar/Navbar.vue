<template>
    <nav v-if="!simulatorMobileStore.showMobileView" class="navbar navbar-expand-lg navbar-dark header">
        <Logo :cvlogo="navbarLogo" />

        <div
            v-if="!simulatorMobileStore.showMobileView"
            id="bs-example-navbar-collapse-1"
            class="collapse navbar-collapse"
        >
            <NavbarLinks :navbar-data="navbarData" />

            <span
                id="projectName"
                class="projectName noSelect defaultCursor font-weight-bold"
            >
                {{ projectStore.getProjectName }}
            </span>
            <UserMenu class="useMenuBtn" />
        </div>
    </nav>
    <QuickButton v-if="!simulatorMobileStore.showMobileView" />
</template>

<script lang="ts" setup>
import QuickButton from '@/Navbar/QuickButton/QuickButton.vue'
import User from '@/Navbar/User/User.vue'
import NavbarLinks from '@/Navbar/NavbarLinks/NavbarLinks.vue'
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore'

import navbarData from '#/assets/constants/Navbar/NAVBAR_DATA.json'
import userDropdownItems from '#/assets/constants/Navbar/USER_DATA.json'

import Logo from '@/Logo/Logo.vue'
import Hamburger from '@/Navbar/Hamburger/Hamburger.vue'
import Hamburger2 from './Hamburger/Hamburger2.vue'
import UserMenu from './User/UserMenu.vue'
import { ref } from 'vue'
import { useProjectStore } from '#/store/projectStore'

const navbarLogo = ref('logo')
const projectStore = useProjectStore()
const simulatorMobileStore = useSimulatorMobileStore()
</script>

<style scoped>
@import './Navbar.css';

.useMenuBtn {
    margin: 0 2rem 0 auto;
}
</style>
