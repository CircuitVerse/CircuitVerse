<template>
  <div class="fields_wrapper">
    <form class="new_subscription" @submit.prevent="createSubscription">
      <div class="fields_title_wrapper">
        <h3 class="fields_title">
          {{ notificationKey }}
        </h3>

        <p>
          <router-link v-bind:to="{ path : $route.path.replace('subscriptions', 'notifications') + '?filtered_by_key=' + notificationKey }">Notifications</router-link>
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
            <label>
              <input type="checkbox" v-model="subscriptionParams.subscribing" v-on:click="arrangeSubscription()" />
              <div class="slider" />
            </label>
          </div>
        </div>
      </div>

      <div v-bind:class="[subscriptionParams.subscribing ? '' : 'hidden', 'field_wrapper subscribing_to_email']">
        <div class="field_label">
          <label>
            Email notification
          </label>
        </div>
        <div class="field">
          <div class="ui checkbox">
            <label>
              <input type="checkbox" v-model="subscriptionParams.subscribing_to_email" />
              <div class="slider" />
            </label>
          </div>
        </div>
      </div>

      <div v-bind:class="[subscriptionParams.subscribing ? '' : 'hidden', 'field_wrapper subscribing_to_optional_targets']">
        <div v-for="optionalTargetName in configuredOptionalTargetNames" :key="optionalTargetName">
          <div class="field_label">
            <label>
              Optional tagret ({{ optionalTargetName }})
            </label>
          </div>
          <div class="field">
            <div class="ui checkbox">
              <label>
                <input type="checkbox" v-model="subscriptionParams.optional_targets[optionalTargetName].subscribing" />
                <div class="slider" />
              </label>
            </div>
          </div>
        </div>
      </div>

      <div class="ui button">
        <button type="submit">Configure subscription</button>
      </div>
    </form>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Subscription',
  props: {
    notificationKey: {
      type: String,
      required: true
    },
    targetApiPath: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      baseURL: axios.defaults.baseURL + this.targetApiPath,
      configuredOptionalTargetNames: [],
      subscriptionParams: {
        key: this.notificationKey,
        subscribing: true,
        subscribing_to_email: true,
        optional_targets: {}
      }
    }
  },
  mounted () {
    axios
      .get(this.targetApiPath + '/subscriptions/optional_target_names?key=' + this.notificationKey)
      .then(response => {
        this.configuredOptionalTargetNames = response.data.optional_target_names;
        for (let optionalTargetName of this.configuredOptionalTargetNames) {
          this.subscriptionParams.optional_targets[optionalTargetName] = {};
          this.subscriptionParams.optional_targets[optionalTargetName].subscribing = true;
        }
      })
      .catch (error => {
        if (error.response.status == 401) {
          this.$router.push('/logout');
        }
      })
  },
  methods: {
    createSubscription () {
      axios
        .post(this.targetApiPath + '/subscriptions', { subscription: this.subscriptionParams })
        .then(response => {
          if (response.status == 201) {
            this.$emit('getSubscriptions');
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    arrangeSubscription () {
      this.subscriptionParams.subscribing_to_email = !this.subscriptionParams.subscribing;
      for (let optionalTargetName of this.configuredOptionalTargetNames) {
        this.subscriptionParams.optional_targets[optionalTargetName].subscribing = !this.subscriptionParams.subscribing;
      }
    }
  }
}
</script>

<style scoped>
</style>