import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedState from "vuex-persistedstate"

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    signedInStatus: false,
    currentUser: null,
    authHeaders: {}
  },
  mutations: {
    signIn(state, { user, authHeaders }) {
      state.currentUser = user;
      state.authHeaders = authHeaders;
      state.signedInStatus = true;
    },
    signOut(state) {
      state.signedInStatus = false;
      state.currentUser = null;
      state.authHeaders = {};
    }
  },
  getters: {
    userSignedIn(state) {
      return state.signedInStatus;
    },
    currentUser(state) {
      return state.currentUser;
    },
    authHeaders(state) {
      return state.authHeaders;
    }
  },
  plugins: [createPersistedState({storage: window.sessionStorage})]
});