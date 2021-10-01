<template>
  <div class="fields_wrapper configured">
    <div class="fields_title_wrapper">
      <h3 class="fields_title">
        {{ subscription.key }}
      </h3>

      <p>
        <router-link v-bind:to="{ path : $route.path.replace('subscriptions', 'notifications') + '?filtered_by_key=' + subscription.key }">Notifications</router-link>
      </p>
    </div>

    <div class="field_wrapper subscribing">
      <div class="field_label">
        <label>
          Notification
        </label>
      </div>
      <div class="field">
        <div class="ui checkbox">
          <div v-if="subscription.subscribing">
            <a href="#" v-on:click="unsubscribe(subscription)" data-remote="true">
              <input type="checkbox" checked="checked" />
              <div class="slider" />
            </a>
          </div>
          <div v-else>
            <a href="#" v-on:click="subscribe(subscription)" data-remote="true">
              <input type="checkbox" />
              <div class="slider" />
            </a>
          </div>
        </div>
      </div>
    </div>

    <div v-bind:class="[subscription.subscribing ? '' : 'hidden', 'field_wrapper subscribing_to_email']">
      <div class="field_label">
        <label>
          Email notification
        </label>
      </div>
      <div class="field">
        <div class="ui checkbox">
          <div v-if="subscription.subscribing_to_email">
            <a href="#" v-on:click="unsubscribe_to_email(subscription)" data-remote="true">
              <label>
                <input type="checkbox" checked="checked" />
                <div class="slider" />
              </label>
            </a>
          </div>
          <div v-else>
            <a href="#" v-on:click="subscribe_to_email(subscription)" data-remote="true">
              <label>
                <input type="checkbox" />
                <div class="slider" />
              </label>
            </a>
          </div>
        </div>
      </div>
    </div>

    <div v-bind:class="[subscription.subscribing ? '' : 'hidden', 'field_wrapper subscribing_to_optional_targets']">
      <div v-for="(optionalTargetSubscription, optionalTargetName) in subscription.optional_targets" :key="optionalTargetName">
        <div class="field_label">
          <label>
            Optional tagret ({{ optionalTargetName }})
          </label>
        </div>
        <div class="field">
          <div class="ui checkbox">
            <div v-if="optionalTargetSubscription.subscribing">
              <a href="#" v-on:click="unsubscribe_to_optional_target(subscription, optionalTargetName)" data-remote="true">
                <label>
                  <input type="checkbox" checked="checked" />
                  <div class="slider" />
                </label>
              </a>
            </div>
            <div v-else>
              <a href="#" v-on:click="subscribe_to_optional_target(subscription, optionalTargetName)" data-remote="true">
                <label>
                  <input type="checkbox" />
                  <div class="slider" />
                </label>
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="ui button">
      <a href="#" v-on:click="destroy(subscription)" data-confirm="Are you sure?" class="button" data-remote="true">Destroy</a>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Subscription',
  props: {
    targetSubscription: {
      type: Object,
      required: true
    },
    targetApiPath: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      subscription: this.targetSubscription,
      baseURL: axios.defaults.baseURL + this.targetApiPath
    }
  },
  methods: {
    subscribe (subscription) {
      axios
        .put(this.targetApiPath + '/subscriptions/' + subscription.id + '/subscribe')
        .then(response => {
          if (response.status == 200) {
            this.subscription = response.data
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    unsubscribe (subscription) {
      axios
        .put(this.targetApiPath + '/subscriptions/' + subscription.id + '/unsubscribe')
        .then(response => {
          if (response.status == 200) {
            this.subscription = response.data
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    subscribe_to_email (subscription) {
      axios
        .put(this.targetApiPath + '/subscriptions/' + subscription.id + '/subscribe_to_email')
        .then(response => {
          if (response.status == 200) {
            this.subscription = response.data
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    unsubscribe_to_email (subscription) {
      axios
        .put(this.targetApiPath + '/subscriptions/' + subscription.id + '/unsubscribe_to_email')
        .then(response => {
          if (response.status == 200) {
            this.subscription = response.data
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    subscribe_to_optional_target (subscription, optionalTargetName) {
      axios
        .put(this.targetApiPath + '/subscriptions/' + subscription.id + '/subscribe_to_optional_target?optional_target_name=' + optionalTargetName)
        .then(response => {
          if (response.status == 200) {
            this.subscription = response.data
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    unsubscribe_to_optional_target (subscription, optionalTargetName) {
      axios
        .put(this.targetApiPath + '/subscriptions/' + subscription.id + '/unsubscribe_to_optional_target?optional_target_name=' + optionalTargetName)
        .then(response => {
          if (response.status == 200) {
            this.subscription = response.data
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    destroy (subscription) {
      axios
        .delete(this.targetApiPath + '/subscriptions/' + subscription.id)
        .then(response => {
          if (response.status == 204) {
            this.$emit('getSubscriptions');
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    }
  }
}
</script>

<style scoped>
</style>