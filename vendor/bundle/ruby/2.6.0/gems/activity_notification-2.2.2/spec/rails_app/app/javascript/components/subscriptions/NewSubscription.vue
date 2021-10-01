<template>
  <div class="fields_wrapper">
    <form class="new_subscription" @submit.prevent="createSubscription">
      <div class="field_wrapper subscribing">
        <div class="field_label">
          <label>
            Notification key
          </label>
        </div>

        <div class="field">
          <div class="ui text_field">
            <input type="text" v-model="subscriptionParams.key" placeholder="Notification key" />
          </div>
        </div>
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

      <div class="ui button">
        <button type="submit">Create subscription</button>
      </div>
    </form>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Subscription',
  props: {
    targetApiPath: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      baseURL: axios.defaults.baseURL + this.targetApiPath,
      subscriptionParams: {
        key: "",
        subscribing: true,
        subscribing_to_email: true,
        optional_targets: {}
      }
    }
  },
  methods: {
    createSubscription () {
      axios
        .post(this.targetApiPath + '/subscriptions', { subscription: this.subscriptionParams })
        .then(response => {
          if (response.status == 201) {
            this.$emit('getSubscriptions');
            this.resetSubscriptionParams();
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
    },
    resetSubscriptionParams () {
      this.subscriptionParams = {
        key: "",
        subscribing: true,
        subscribing_to_email: true,
        optional_targets: {}
      }
    }
  }
}
</script>

<style scoped>
</style>