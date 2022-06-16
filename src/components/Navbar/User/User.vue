<template>
    <ul class="nav navbar-nav noSelect pointerCursor pull-right account-btn">
        <li class="dropdown pull-right" v-if="isUserSignedIn === true">
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
            <DropDown :listItems="userData" dropDownType="user" />
        </li>
        <li class="dropdown pull-right" v-else>
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
    props: {
        isUserSignedIn: {
            type: Boolean,
            default: false,
        },
        userData: Array,
    },
    components: {
        DropDown,
    },
}
</script>

<style scoped>
/* @import url('./User.css'); */
</style>
