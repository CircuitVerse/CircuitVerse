<template>
  <div>
    <section>
      <h1>Authentecated User</h1>
      <div class="list_wrapper">
        <div class="list_image"></div>
        <div class="list_description_wrapper">
          <div class="list_description">
            <div v-if="userSignedIn">
              <span>{{ currentUser.name }}</span> · {{ currentUser.email }} · <router-link v-bind:to="{ path: '/logout' }">Logout</router-link><br>
            </div>
            <div v-else>
              <span>Not logged in</span> · <router-link v-bind:to="{ path: '/login' }">Login</router-link><br>
            </div>
            <router-link v-bind:to="{ name : 'AuthenticatedUserNotificationsIndex' }">Notifications</router-link> /
            <router-link v-bind:to="{ name : 'AuthenticatedUserSubscriptionsIndex' }">Subscriptions</router-link>
          </div>
        </div>
      </div>
    </section>

    <section>
      <h1>Listing Users</h1>
      <div v-for="user in users" :key="`${user.id}`" class="list_wrapper">
        <div class="list_image"></div>
        <div class="list_description_wrapper">
          <p class="list_description">
            <span>{{ user.name }}</span> · {{ user.email }}<br>
            <router-link v-bind:to="{ name : 'UnauthenticatedTargetNotificationsIndex', params : { target_type: 'users', target_id: user.id, target: user }}">Notifications</router-link> /
            <router-link v-bind:to="{ name : 'UnauthenticatedTargetSubscriptionsIndex', params : { target_type: 'users', target_id: user.id, target: user }}">Subscriptions</router-link>
          </p>
        </div>
      </div>
    </section>

    <section>
      <h1>Authentecated User as Admin</h1>
      <div class="list_wrapper">
        <div class="list_image"></div>
        <div class="list_description_wrapper">
          <div class="list_description">
            <div v-if="userSignedIn">
              <span>{{ currentUser.name }}</span> · {{ currentUser.email }} · <span v-if="currentUser.admin">(admin)</span><span v-else>(not admin)</span><br>
            </div>
            <div v-else>
              <span>Not logged in</span> · <router-link v-bind:to="{ path: '/login' }">Login</router-link><br>
            </div>
            <router-link v-bind:to="{ name : 'AuthenticatedAdminNotificationsIndex' }">Notifications</router-link> /
            <router-link v-bind:to="{ name : 'AuthenticatedAdminSubscriptionsIndex' }">Subscriptions</router-link>
          </div>
        </div>
      </div>
    </section>

    <section>
      <h1>Listing Admins</h1>
      <div v-for="admin in admins" :key="`${admin.id}`" class="list_wrapper">
        <div class="list_image"></div>
        <div class="list_description_wrapper">
          <p class="list_description">
            <span>{{ admin.user.name }}</span> · {{ admin.user.email }}<br>
            <router-link v-bind:to="{ name : 'UnauthenticatedTargetNotificationsIndex', params : { target_type: 'admins', target_id: admin.id, target: admin }}">Notifications</router-link> /
            <router-link v-bind:to="{ name : 'UnauthenticatedTargetSubscriptionsIndex', params : { target_type: 'admins', target_id: admin.id, target: admin }}">Subscriptions</router-link>
          </p>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Top',
  data () {
    return {
      userSignedIn: this.$store.getters.userSignedIn,
      currentUser: this.$store.getters.currentUser,
      users: [],
      admins: []
    }
  },
  mounted () {
    axios
      .get('/users')
      .then(response => {
        this.users = response.data.users;
        this.admins = this.users
          .filter(user => user.admin)
          .map(user => Object.assign(Object.create(user.admin), { user: user }))
      })
  }
}
</script>

<style scoped>
</style>