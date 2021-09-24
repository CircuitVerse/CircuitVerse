<template>
  <div class="subscription_wrapper">
    <div class="subscription_header">
      <h1>Subscriptions for {{ currentTarget.printable_target_name }}</h1>
    </div>

    <div v-if="subscriptions">
      <div class="subscription_header">
        <h2>Configured subscriptions</h2>
      </div>
      <div class="subscriptions" id="subscriptions">
        <div v-if="subscriptions.length" class="fields_area">
          <div v-for="subscription in subscriptions" :key="`${subscription.id}_${subscription.updated_at}`">
            <subscription :targetSubscription="subscription" :targetApiPath="targetApiPath" @getSubscriptions="getSubscriptions" />
          </div>
        </div>
        <div v-else class="fields_area">
          <div class="fields_wrapper">
            No subscriptions are available.
          </div>
        </div>
      </div>
    </div>

    <div v-if="notificationKeys">
      <div class="subscription_header">
        <h2>Unconfigured notification keys</h2>
      </div>
      <div class="notification_keys" id="notification_keys">
        <div v-if="notificationKeys.length" class="fields_area">
          <div v-for="notificationKey in notificationKeys" :key="notificationKey">
            <notification-key :notificationKey="notificationKey" :targetApiPath="targetApiPath" @getSubscriptions="getSubscriptions" />
          </div>
        </div>
        <div v-else class="fields_area">
          <div class="fields_wrapper">
            No notification keys are available.
          </div>
        </div>
      </div>
    </div>

    <div class="subscription_header">
      <h2>Create a new subscription</h2>
    </div>
    <div class="subscription_form" id="subscription_form">
      <div class="fields_area">
        <new-subscription :targetApiPath="targetApiPath" @getSubscriptions="getSubscriptions" />
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import Subscription from './Subscription.vue'
import NotificationKey from './NotificationKey.vue'
import NewSubscription from './NewSubscription.vue'

export default {
  name: 'SubscriptionsIndex',
  components: {
    Subscription,
    NotificationKey,
    NewSubscription
  },
  props: {
    target_type: {
      type: String
    },
    target_id: {
      type: [String, Number]
    },
    targetApiPath: {
      type: String,
      default: function () { 
        if (this.target_type && this.target_id) {
          return '/' + this.target_type + '/' + this.target_id;
        } else {
          return '';
        }
      }
    },
    target: {
      type: Object
    }
  },
  data () {
    return {
      currentTarget: { printable_target_name: '' },
      subscriptions: [],
      notificationKeys: []
    }
  },
  mounted () {
    if (this.target) {
      this.currentTarget = this.target;
    } else {
      this.getCurrentTarget();
    }
    this.getSubscriptions();
  },
  methods: {
    getCurrentTarget () {
      axios
        .get(this.targetApiPath)
        .then(response => (this.currentTarget = response.data))
    },
    getSubscriptions () {
      axios
        .get(this.targetApiPath + '/subscriptions')
        .then(response => {
          this.subscriptions = response.data.subscriptions;
          this.notificationKeys = response.data.unconfigured_notification_keys;
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
.subscription_header h1 {
  margin-bottom: 30px;
}

.fields_area {
  border: 1px solid #e5e5e5;
  width: 600px;
  box-sizing: border-box;
  margin-bottom: 30px;
}
</style>

<style>
.fields_area .fields_wrapper {
  position: relative;
  background-color: #fff;
  padding: 20px;
  box-sizing: border-box;
  border-bottom: 1px solid #e5e5e5;
}
.fields_area .fields_wrapper.configured {
  background-color: #f8f9fb;
}

.fields_area .fields_wrapper .fields_title_wrapper {
  margin-bottom: 16px;
  border-bottom: none;
}

.fields_area .fields_wrapper .fields_title_wrapper .fields_title {
  font-size: 16px;
  font-weight: bold;
}

.fields_area .fields_wrapper .fields_title_wrapper p {
  position: absolute;
  top: 15px;
  right: 15px;
}

.fields_area .fields_wrapper .field_wrapper {
  margin-bottom: 16px;
}

.fields_area .fields_wrapper .field_wrapper:last-child {
  margin-bottom: 0;
}

.fields_area .fields_wrapper .field_wrapper.hidden {
  display: none;
}

.fields_area .fields_wrapper .field_wrapper .field_label {
  margin-bottom: 8px;
}

.fields_area .fields_wrapper .field_wrapper .field_label label {
  font-size: 14px;
}

.ui label {
  font-size: 14px;
}

/* button */
.ui.button button,
.ui.button .button {
  cursor: pointer;
  color: #4f4f4f;
  font-weight: bold;
  font-size: 12px;
  padding: 10px 14px;
  margin-left: 10px;
  border: 1px solid #e5e5e5;
  background-color: #fafafa;
}

.ui.button button:first-child,
.ui.button .button:first-child {
  margin-left: 0;
}

.ui.text_field input {
  margin: 0;
  outline: 0;
  padding: 10px;
  font-size: 14px;
  border: 1px solid #e5e5e5;
  border-radius: 3px;
  box-shadow: 0 0 0 0 transparent inset;
}

/* checkbox */
.ui.checkbox {
  position: relative;
  left: 300px;
  margin-top: -26px;
  width: 40px;
}

.ui.checkbox input {
  position: absolute;
  margin-left: -9999px;
  visibility: hidden;
}

.ui.checkbox .slider {
  display: block;
  position: relative;
  cursor: pointer;
  outline: none;
  user-select: none;

  padding: 2px;
  width: 36px;
  height: 20px;
  background-color: #dddddd;
  border-radius: 20px;
}

.ui.checkbox .slider:before,
.ui.checkbox .slider:after {
  display: block;
  position: absolute;
  top: 1px;
  left: 1px;
  bottom: 1px;
  content: "";
}

.ui.checkbox .slider:before {
  right: 1px;
  background-color: #f1f1f1;
  border-radius: 20px;
  transition: background 0.4s;
}

.ui.checkbox .slider:after {
  width: 20px;
  background-color: #fff;
  border-radius: 100%;
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.3);
  transition: margin 0.4s;
}

.ui.checkbox input:checked + .slider:before {
  background-color: #8ce196;
}

.ui.checkbox input:checked + .slider:after {
  margin-left: 18px;
}
</style>