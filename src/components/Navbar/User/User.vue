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
            <!-- <ul class="dropdown-menu">
                <li 
                    :key="userDropdownItem.id" 
                    v-for="userDropdownItem in userData"
                >
                    <a class="dropdown-item" >
                        {{userDropdownItem.item}}
                    </a>
                </li>
                <div class="dropdown-divider"></div>
                <li>
                    <a class="dropdown-item" rel="nofollow" data-method="delete">Sign Out</a>
                </li>
            </ul> -->
            <DropDown :list-items="userData" drop-down-type="user" />
        </li>
        <li v-else class="dropdown pull-right">
            <a
                class="navbar-nav signIn-btn user-field"
                href="https://circuitverse.org/users/sign_in"
            >
                Sign In
            </a>
        </li>
    </ul>
</template>

<script>
import DropDown from '../../Dropdown/DropDown.vue'

export default {
    name: 'User',
    components: {
        DropDown,
    },
    props: {
        isUserSignedIn: {
            type: Boolean,
            default: false,
        },
        userData: Array,
    },
}
</script>

<style scoped>
/* @import url('./User.css'); */
</style>
