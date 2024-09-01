<template v-else>
  <UserMenu :style="{width: 0}" class="userMenuHamBurger" v-bind="userMenuState" />
  <v-card id="toolbar" color="transparent" variant="outlined">
      <v-layout>
          <v-navigation-drawer
              class="navDrawer"
              v-model="navDrawer"
              location="right"
              temporary
          >
              <div class="close-parent">
                  <v-btn
                      size="x-small"
                      icon
                      class="dialogClose navDrawerClose"
                      @click="
                          navDrawer = !navDrawer
                      "
                  >
                      <v-icon style="font-size: 1.5rem;">mdi-arrow-right</v-icon>
                  </v-btn>
              </div>
              <v-list-item class="d-flex justify-center align-center">
                  <span>Project Name: &nbsp;</span>
                  <span style="font-size: 1.5rem">
                      {{ projectStore.getProjectName }}
                  </span>
              </v-list-item>

              <v-divider></v-divider>

              <v-list class="navDrawerList1" density="compact">
                  <v-list-item
                      class="navDrawerList1Item"
                      v-for="navbarItem in navbarData"
                      :key="navbarItem.id"
                  >
                      <NavbarLink2 :navbar-item="navbarItem" />
                  </v-list-item>
              </v-list>
              <v-divider></v-divider>
              <v-btn
                  color="transparent"
                  style="width: 100%"
                  flat
                  @click="userMenuClick"
              >
                  <v-list-item
                      class="list-item-avatar"
                      :prepend-avatar="authStore.getUserAvatar"
                      :prepend-icon="
                          authStore.getUserAvatar === 'default'
                              ? 'mdi-account-circle-outline'
                              : ''
                      "
                      :title="authStore.getUsername"
                  ></v-list-item>
              </v-btn>
          </v-navigation-drawer>
          <v-btn
              class="navDrawerButton"
              color="transparent"
              flat
              icon
              @click="navDrawer = !navDrawer"
              :class="{ active: navDrawer }"
          >
              <v-icon>mdi-menu</v-icon>
          </v-btn>
      </v-layout>
  </v-card>
</template>

<script lang="ts" setup>
// import { useState } from '#/store/SimulatorStore/state'
import { useAuthStore } from '#/store/authStore'
import { useProjectStore } from '#/store/projectStore'
import { ref } from 'vue'
import UserMenu from '../User/UserMenu.vue'
import NavbarLink2 from '../NavbarLinks/NavbarLink/NavbarLink2.vue'
defineProps({
  navbarData: { type: Array, default: () => [] },
})
// const SimulatorState = useState()
const authStore = useAuthStore()
const projectStore = useProjectStore()
const navDrawer = ref(false)
const userMenuState = ref()
function userMenuClick() {
  const userMenuBtn = document.querySelector('.avatar-btn') as HTMLElement
  if (userMenuBtn) {
      userMenuBtn.click()
      navDrawer.value = false
  }
}
</script>

<style>
.navDrawer {
  /* height: auto; */
  /* width: 760px; */
  /* justify-content: center; */
  /* margin: auto; */
  backdrop-filter: blur(5px) !important;
  border-radius: 5px !important;
  border: 0.5px solid var(--br-primary) !important;
  background: var(--bg-primary-moz) !important;
  background-color: var(--bg-primary-chr) !important;
  color: white !important;
}
.navDrawerList1 {
  background-color: transparent !important;
  color: white !important;
}
.navDrawerList1 .v-btn {
  width: 100% !important;
  height: 2.5rem !important;
  margin: auto !important;
}
.navDrawerButton {
  color: white !important;
  height: auto !important;
  width: auto !important;
}
.userMenuHamBurger {
  z-index: 1005 !important;
}
.userMenuHamBurger .avatar-btn {
  /* display: hidden !important; */
  visibility: hidden !important;
}

.close-parent {
  height: 2rem;
  display: flex;
  justify-content: end;
}

.navDrawerClose {
  position: relative;
}
</style>