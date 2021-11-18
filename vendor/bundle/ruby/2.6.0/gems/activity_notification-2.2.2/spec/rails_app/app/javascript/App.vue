<template>
  <div>
    <router-view />
  </div>
</template>

<script>
import Vue from 'vue'
import VueMoment from 'vue-moment'
import moment from 'moment-timezone'
import VuePluralize from 'vue-pluralize'
import ActionCableVue from 'actioncable-vue'
import axios from 'axios'
import env from './config/environment'

axios.defaults.baseURL = "/api/v2"

Vue.use(VueMoment, { moment })
Vue.use(VuePluralize)
Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: 'error',
  connectionUrl: env.ACTION_CABLE_CONNECTION_URL,
  connectImmediately: true
})

export default {
  name: 'App',
  mounted () {
    if (this.$store.getters.userSignedIn) {
      for (var authHeader of Object.keys(this.$store.getters.authHeaders)) {
        axios.defaults.headers.common[authHeader] = this.$store.getters.authHeaders[authHeader];
      }
    }
  }
}
</script>

<style scoped>
</style>