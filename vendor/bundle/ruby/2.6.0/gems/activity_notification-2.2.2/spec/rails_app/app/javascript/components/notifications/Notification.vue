<template>
  <div v-bind:class="`notification_${notification.id}`">
    <div v-if="!notification.opened_at">
      <a href="#" v-on:click="open(notification)" data-remote="true" class="unopened_wrapper">
        <div class="unopened_circle"></div>
        <div class="unopened_description_wrapper">
          <p class="unopened_description">Open</p>
        </div>
      </a>
      <a href="#" v-on:click="move(notification, '?open=true')" data-remote="true">
        <notification-content :notification="notification" />
      </a>
      <div class="unopened_wrapper"></div>
    </div>
    <div v-else>
      <a href="#" v-on:click="move(notification, '')" data-remote="true">
        <notification-content :notification="notification" />
      </a>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import NotificationContent from './NotificationContent.vue'

export default {
  name: 'Notification',
  components: {
    NotificationContent
  },
  props: {
    targetNotification: {
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
      notification: this.targetNotification,
      baseURL: axios.defaults.baseURL + this.targetApiPath
    }
  },
  methods: {
    open (notification) {
      axios
        .put(this.targetApiPath + '/notifications/' + notification.id + '/open')
        .then(response => {
          if (response.status == 200) {
            this.$emit('getUnopenedNotificationCount')
            this.notification = response.data.notification
          }
        })
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    move (notification, paramsString) {
      axios
        .get(this.targetApiPath + '/notifications/' + notification.id + '/move' + paramsString)
        .then(response => {
          if (response.status == 200) {
            window.location.href = response.request.responseURL;
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
/* unopened_circle */
.unopened_wrapper{
  position: absolute;
  margin-top: 20px;
  margin-left: 56px;
}
.unopened_wrapper .unopened_circle {
  display: block;
  width: 10px;
  height: 10px;
  position: absolute;
  border-radius: 50%;
  background-color: #27a5eb;
  z-index: 2;
}
.unopened_wrapper:hover > .unopened_description_wrapper{
  display: block;
}
.unopened_wrapper .unopened_description_wrapper {
  display: none;
  position: absolute;
  margin-top: 26px;
  margin-left: -24px;
}
.unopened_wrapper .unopened_description_wrapper .unopened_description {
  position: absolute;
  color: #fff;
  font-size: 12px;
  text-align: center;

  border-radius: 4px;
  background: rgba(0, 0, 0, 0.8);
  padding: 4px 12px;
  z-index: 999;
}
.unopened_wrapper .unopened_description_wrapper .unopened_description:before {
    border: solid transparent;
    border-top-width: 0;
    content: "";
    display: block;
    position: absolute;
    width: 0;
    left: 50%;
    top: -5px;
    margin-left: -5px;
    height: 0;
    border-width: 0 5px 5px 5px;
    border-color: transparent transparent rgba(0, 0, 0, 0.8) transparent;
    z-index: 0;
}
</style>