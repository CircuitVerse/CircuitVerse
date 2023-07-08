<template>
    <ul class="nav navbar-nav noSelect pointerCursor pull-right account-btn">
        <li v-if="authStore.getIsLoggedIn === true" class="dropdown pull-right">
            <!-- @devartstar When integrating with Project remove v-if from above li and also v-else as it is handled by backend -->
            <a
                href="#"
                class="cur-user acc-drop user-field"
                data-toggle="dropdown"
                role="button"
                aria-haspopup="true"
                aria-expanded="false"
                >{{ authStore.getUsername }}<span class="caret acc-caret"></span
            ></a>
            <DropDown
                :list-items="userData"
                drop-down-header="user_dropdown"
                drop-down-type="user"
            />
        </li>
        <li v-else class="dropdown pull-right">
            <a class="navbar-nav signIn-btn user-field" href="/users/sign_in">
                {{ $t('simulator.nav.sign_in') }}
            </a>
        </li>
    </ul>
</template>

<script lang="ts" setup>
import { useAuthStore } from '#/store/authStore'
import DropDown from '@/Dropdown/DropDown.vue'
const authStore = useAuthStore()

defineProps({
    userData: { type: Array<{
        id: string
        item: string
        itemid: string
        attributes: Array<{
            name: string
            value: string
        }>
    }>, default: () => [] },
})
</script>

<style scoped>
/* @import url('./User.css'); */
a:link,
a:hover,
a:hover,
a:active {
    text-decoration: none;
    color: #fff;
}
</style>
