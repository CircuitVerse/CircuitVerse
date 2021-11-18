<template>
  <div id="login">
    <h2>Log in</h2>
    <form class="new_user" @submit.prevent="login">
      <div class="field">
        <label for="user_email">Email</label><br />
        <input v-model="loginParams.email" autofocus="autofocus" autocomplete="email" type="email" value="" name="user[email]" id="user_email" />
      </div>
      <div class="field">
        <label for="user_password">Password</label><br />
        <input v-model="loginParams.password" autocomplete="current-password" type="password" name="user[password]" id="user_password" />
      </div>
      <div class="actions">
        <input type="submit" name="commit" value="Log in" data-disable-with="Log in" />
      </div>
    </form>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'DeviseTokenAuth',
  props: {
    isLogout: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      loginParams: {
        email: "",
        password: ""
      }
    }
  },
  mounted () {
    if (this.isLogout) {
      this.logout();
    }
  },
  methods: {
    login () {
      axios
        .post('/auth/sign_in', { email: this.loginParams.email, password: this.loginParams.password })
        .then(response => {
          if (response.status == 200) {
            let authHeaders = {};
            for (let authHeader of ['access-token', 'client', 'uid']) {
              authHeaders[authHeader] = response.headers[authHeader];
              axios.defaults.headers.common[authHeader] = authHeaders[authHeader];
            }
            this.$store.commit('signIn', { user: response.data.data, authHeaders: authHeaders });
            if (this.$route.query.redirect) {
              this.$router.push(this.$route.query.redirect);
            } else {
              this.$router.push('/');
            }
          }
        })
        .catch (error => {
          console.log("Authentication failed");
          if (error.response.status == 401) {
            this.$router.go({path: this.$router.currentRoute.path});
          }
        })
    },
    logout () {
      for (var authHeader of Object.keys(this.$store.getters.authHeaders)) {
        delete axios.defaults.headers.common[authHeader];
      }
      this.$store.commit('signOut');
      this.$router.push('/');
    }
  }
}
</script>

<style scoped>
</style>