<template>
    <template v-if="isLoading">
        <h1>Loading...</h1>
    </template>
    <template v-else-if="!isLoading && !hasAccess">
        <h1>403</h1>
    </template>
    <template v-else-if="!isLoading && hasAccess">
        <simulator />
    </template>
</template>

<script lang="ts">
export function getToken(name: string) {
    var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'))
    if (match) return match[2]
}
</script>

<script setup lang="ts">
import simulator from './simulator.vue'
import { onBeforeMount, ref } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '#/store/authStore'

const route = useRoute()
const hasAccess = ref(true)
const isLoading = ref(true)
const authStore = useAuthStore()

// check if user has edit access to the project
async function checkEditAccess() {
    await fetch(`/api/v1/projects/${window.logixProjectId}/check_edit_access`, {
        method: 'GET',
        headers: {
            Accept: 'application/json',
            Authorization: `Token ${getToken('cvt')}`,
        },
    }).then((res) => {
        // if user has edit access load circuit data
        if (res.ok) {
            res.json().then((data) => {
                authStore.setUserInfo(data.data)
                ;(window as any).isUserLoggedIn = true
                isLoading.value = false
            })
        } else if (res.status === 403) {
            // if user has no edit access show edit access denied page
            hasAccess.value = false
            isLoading.value = false
        } else if (res.status === 404) {
            hasAccess.value = false
            isLoading.value = false
        } else if (res.status === 401) {
            // if user is not logged in redirect to login page
            window.location.href = '/users/sign_in'
        }
    })
}

// get logged in user informaton when blank simulator is opened
async function getLoginData() {
    try {
        const response = await fetch('/api/v1/me', {
            method: 'GET',
            headers: {
                Accept: 'application/json',
                Authorization: `Token ${getToken('cvt')}`,
            },
        })
        if (response.ok) {
            const data = await response.json()
            authStore.setUserInfo(data.data)
            ;(window as any).isUserLoggedIn = true
        } else if (response.status === 401) {
            ;(window as any).isUserLoggedIn = false
        }
    } catch (err) {
        console.error(err)
    }
}

onBeforeMount(() => {
    // set project id if /edit/:projectId route is used

    ;(window as any).logixProjectId = route.params.projectId
    // only execute if projectId is defined
    if ((window as any).logixProjectId) {
        checkEditAccess()
    } else {
        // if projectId is not defined open blank simulator
        getLoginData()
        isLoading.value = false
    }
})
</script>
