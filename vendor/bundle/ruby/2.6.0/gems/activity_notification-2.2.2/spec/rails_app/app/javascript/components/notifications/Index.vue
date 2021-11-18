<template>
  <div class="notification_wrapper">
    <div class="notification_header">
      <h1>
        Notifications to {{ currentTarget.printable_target_name }}
        <a href="#" v-on:click="openAll()" data-remote="true">
          <span class="notification_count"><span v-bind:class="[unopenedNotificationCount > 0 ? 'unopened' : '']">
            {{ unopenedNotificationCount }}
          </span></span>
        </a>
      </h1>
      <h3>
        <span class="action_cable_status">{{ actionCableStatus }}</span>
      </h3>
    </div>
    <div class="notifications">
      <div v-for="notification in notifications" :key="`${notification.id}_${notification.opened_at}_${notification.group_notification_count}`">
        <notification :targetNotification="notification" :targetApiPath="targetApiPath" @getUnopenedNotificationCount="getUnopenedNotificationCount" />
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import Push from 'push.js'
import Notification from './Notification.vue'

export default {
  name: 'NotificationsIndex',
  components: {
    Notification
  },
  props: {
    target_type: {
      type: String,
      required: true
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
      unopenedNotificationCount: 0,
      notifications: [],
      actionCableStatus: "Disabled"
    }
  },
  mounted () {
    if (this.target) {
      this.currentTarget = this.target;
      this.subscribeActionCable();
    } else {
      this.getCurrentTarget();
    }
    this.getNotifications();
    this.getUnopenedNotificationCount();
  },
  channels: {
    'ActivityNotification::NotificationApiChannel': {
      connected() {
        this.actionCableStatus = "Online";
      },
      disconnected() {
        this.actionCableStatus = "Offline";
      },
      rejected() {
        this.actionCableStatus = "Offline (unauthorized)";
      },
      received(data) {
        this.notify(data);
      }
    },
    'ActivityNotification::NotificationApiWithDeviseChannel': {
      connected() {
        this.actionCableStatus = "Online (authorized)";
      },
      disconnected() {
        this.actionCableStatus = "Offline";
      },
      rejected() {
        this.actionCableStatus = "Offline (unauthorized)";
      },
      received(data) {
        this.notify(data);
      }
    }
  },
  methods: {
    getCurrentTarget () {
      axios
        .get(this.targetApiPath)
        .then(response => {
          this.currentTarget = response.data;
          this.subscribeActionCable();
        })
    },
    getNotifications () {
      axios
        .get(this.targetApiPath + '/notifications', { params: this.$route.query })
        .then(response => (this.notifications = response.data.notifications))
        .catch (error => {
          if (error.response.status == 401) {
            this.$router.push('/logout');
          }
        })
    },
    getUnopenedNotificationCount () {
      if (this.$route.query.filter == 'opened') {
        this.unopenedNotificationCount = 0;
      } else {
        axios
          .get(this.targetApiPath + '/notifications', { params: Object.assign({ filter: 'unopened' }, this.$route.query) })
          .then(response => (this.unopenedNotificationCount = response.data.count))
          .catch (error => {
            if (error.response.status == 401) {
              this.$router.push('/logout');
            }
          })
      }
    },
    openAll () {
      axios
        .post(this.targetApiPath + '/notifications/open_all')
        .then(response => {
          if (response.status == 200) {
            this.getNotifications();
            this.getUnopenedNotificationCount();
          }
        })
    },
    subscribeActionCable () {
      if (this.currentTarget['notification_action_cable_allowed?']) {
        if (!this.currentTarget['notification_action_cable_with_devise?']) {
          this.$cable.subscribe({
            channel: 'ActivityNotification::NotificationApiChannel',
            target_type: this.target_type, target_id: this.currentTarget.id
          });
        } else {
          this.$cable.subscribe({
            channel: 'ActivityNotification::NotificationApiWithDeviseChannel',
            target_type: this.target_type, target_id: this.currentTarget.id,
            'access-token': axios.defaults.headers.common['access-token'],
            'client': axios.defaults.headers.common['client'],
            'uid': axios.defaults.headers.common['uid']
          });
        }
      }
    },
    notify (data) {
      // Display notification
      if (data.group_owner == null) {
        this.notifications.unshift(data.notification);
        this.getUnopenedNotificationCount();
      } else {
        this.notifications.splice(this.notifications.findIndex(n => n.id === data.group_owner.id), 1);
        this.notifications.unshift(data.group_owner);
        this.getUnopenedNotificationCount();
      }
      // Push notificaion using Web Notification API by Push.js
      Push.create('ActivityNotification', {
        body: data.notification.text,
        timeout: 5000,
        onClick: function () {
          location.href = data.notification.notifiable_path;
          this.close();
        }
      });
    }
  }
}
</script>

<style scoped>
.notification_wrapper .notification_header h1 span span{
  color: #fff;
  background-color: #e5e5e5;
  border-radius: 4px;
  font-size: 12px;
  padding: 4px 8px;
}
.notification_wrapper .notification_header h1 span span.unopened{
  background-color: #f87880;
}
</style>