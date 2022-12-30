<template>
    <ul class="nav navbar-nav noSelect pointerCursor pull-right account-btn">
        <li v-if="isUserSignedIn === true" class="dropdown pull-right">
            <!-- When integrating with Project remove v-if from above li and also v-else as it is handled by backend -->
            <a
                href="#"
                class="cur-user acc-drop user-field"
                data-toggle="dropdown"
                role="button"
                aria-haspopup="true"
                aria-expanded="false"
                >Devjit Choudhury<span class="caret acc-caret"></span
            ></a>
            <DropDown
                :list-items="userData"
                drop-down-header="user_dropdown"
                drop-down-type="user"
            />
        </li>
        <li v-else class="dropdown pull-right">
            <a
                class="navbar-nav signIn-btn user-field"
                href="https://circuitverse.org/users/sign_in"
            >
                {{ $t('simulator.nav.sign_in') }}
            </a>
        </li>
    </ul>
</template>

<script lang="ts" setup>
import DropDown from '@/Dropdown/DropDown.vue'

const props = defineProps({
    isUserSignedIn: { type: Boolean, default: false },
    userData: { type: Array, default: () => [] },
})
</script>

<style scoped>
/* @import url('./User.css'); */
</style>
