<template>
  <v-card class="avatar-menu">
      <v-layout>
          <v-navigation-drawer
              v-model="drawer"
              location="right"
              class="userMenu"
              temporary
          >
              <div class="close-parent">
                  <v-btn
                      size="x-small"
                      icon
                      class="dialogClose"
                      @click="
                          drawer = !drawer
                      "
                  >
                      <v-icon style="font-size: 1.5rem;">mdi-arrow-right</v-icon>
                  </v-btn>
              </div>
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
              <v-list-item>
                  <v-select
                      :items="availableLocale"
                      label="Locale"
                      v-model="locale"
                      density="compact"
                      outlined
                      dense
                      hide-details
                  ></v-select>
              </v-list-item>
              <v-divider></v-divider>

              <div v-if="!authStore.getIsLoggedIn">
                  <v-list dense class="userMenuList1" nav>
                      <v-list-item
                          @click.stop="signin"
                          prepend-icon="mdi-login"
                          title="Sing In"
                          value="sign_in"
                      ></v-list-item>
                      <v-list-item
                          @click.stop="register"
                          prepend-icon="mdi-account-plus"
                          title="Register"
                          value="register"
                      ></v-list-item>
                  </v-list>
              </div>

              <div v-if="authStore.getIsLoggedIn">
                  <v-list density="compact" class="userMenuList1" nav>
                      <v-list-item
                          @click.stop="dashboard"
                          prepend-icon="mdi-view-dashboard-outline"
                          title="Dashboard"
                          value="dashboard"
                      ></v-list-item>
                      <v-list-item
                          @click.stop="my_groups"
                          prepend-icon="mdi-account-group-outline"
                          title="My Groups"
                          value="my_groups"
                      ></v-list-item>
                      <v-list-item
                          @click.stop="notifications"
                          prepend-icon="mdi-bell-outline"
                          title="Notifications"
                          value="notifications"
                      ></v-list-item>
                  </v-list>
                  <v-divider></v-divider>
                  <v-list-item
                      @click.stop="signout"
                      prepend-icon="mdi-logout"
                      title="Logout"
                      value="logout"
                  ></v-list-item>
              </div>
          </v-navigation-drawer>
          <v-main>
              <!-- <div class=""> -->
              <v-btn
                  class="avatar-btn"
                  color="transparent"
                  @click.stop="drawer = !drawer"
              >
                  <v-icon
                      v-if="authStore.getUserAvatar == 'default'"
                      class="avatar"
                      size="x-large"
                      >mdi-account</v-icon
                  >
                  <v-avatar
                      v-else
                      class="avatar"
                      size="small"
                      :image="authStore.getUserAvatar"
                  ></v-avatar>
                  {{ authStore.getUsername }}
              </v-btn>
              <!-- </div> -->
          </v-main>
      </v-layout>
  </v-card>
</template>
<script lang="ts" setup>
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { availableLocale } from '#/locales/i18n'
import { useAuthStore } from '#/store/authStore'
const authStore = useAuthStore()
const drawer = ref(false)
const { locale } = useI18n()
function signin() {
  window.location.href = '/users/sign_in'
}
function register() {
  window.location.href = '/users/sign_up'
}
function dashboard() {
  window.location.href = `/users/${authStore.getUserId}`
}
function my_groups() {
  window.location.href = `/users/${authStore.getUserId}/groups`
}
function notifications() {
  window.location.href = `/users/${authStore.getUserId}/notifications`
}
function signout() {
  window.location.href = '/users/sign_out'
}
</script>

<style>
.userMenu {
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
/* media query for .messageBoxContent */
/* @media screen and (max-width: 991px) {
  .userMenu {
      width: 100%;
  }
} */
.userMenuList1 {
  background-color: transparent !important;
  color: #fff !important;
}
.avatar-menu {
  /* border-radius: 50% !important; */
  background-color: transparent !important;
  box-shadow: none !important;
}
.avatar-btn {
  color: #fff !important;
  text-transform: none !important;
  font-size: 1rem !important;
}
.list-item-avatar .v-list-item-title {
  color: #fff !important;
  font-size: 1.2rem !important;
}
.list-item-avatar img {
  display: inline-block;
}
.avatar img {
  cursor: pointer;
  display: inline-block;
}
</style>