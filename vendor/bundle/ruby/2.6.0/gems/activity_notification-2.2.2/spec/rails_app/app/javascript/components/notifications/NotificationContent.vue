<template>
  <div v-bind:class="[notification.opened_at ? 'opened' : 'unopened', 'notification_list']">
    <div class="notification_list_cover"></div>
    <div class="list_image"></div>
    <div class="list_text_wrapper">
      <!-- Custom view -->
      <p v-if="notification.key == 'article.update'" class="list_text">
        <strong>{{ notification.notifier.name }}</strong> updated his or her article "{{ notification.notifiable.title }}".
        <br>
        <span class="created_at">{{ new Date(notification.created_at) | moment('timezone', 'UTC', "MMM DD HH:mm") }}</span>
      </p>
      <!-- Default view -->
      <p v-else class="list_text">
        <strong v-if="notification.notifier">{{ notification.notifier.printable_notifier_name }}</strong>
        <strong v-else>Someone</strong>
        <span v-if="notification.group_member_notifier_count > 0">
          and {{ notification.group_member_notifier_count }} other
          <span v-if="notification.notifier">{{ notification.notifier.printable_type.toLowerCase() | pluralize(notification.group_member_notifier_count) }}</span>
          <span v-else>people</span>
        </span>
        notified you of
        <span v-if="notification.notifiable" key="notification-group">
          <span v-if="notification.group_members.length">
            {{ notification.group_notification_count }} {{notification.notifiable_type.toLowerCase() | pluralize(notification.group_notification_count) }} including
          </span>
          {{ notification.printable_notifiable_name }}
          <span v-if="notification.group"> in {{ notification.group.printable_group_name }}</span>
        </span>
        <span v-else key="notification-group">
          <span v-if="notification.group_members.length" key="group-members">
            {{ notification.group_notification_count }} {{notification.notifiable_type.toLowerCase() | pluralize(notification.group_notification_count) }}
          </span>
          <span v-else key="group-members">
            a {{ notification.notifiable_typetoLowerCase() | pluralize(0) }}
          </span>
          <span v-if="notification.group"> in {{ notification.group.printable_group_name }}</span>
          but the notifiable is not found. It may have been deleted.
        </span>
        <br>
        <span class="created_at">{{ new Date(notification.created_at) | moment('timezone', 'UTC', "MMM DD hh:mm") }}</span>
      </p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NotificationContent',
  props: {
    notification: {
      type: Object,
      required: true
    }
  }
}
</script>

<style scoped>
/* list */
.notification_list {
  padding: 15px 10px;
  position: relative;
  border-bottom: 1px solid #e5e5e5;
}
.notification_list.unopened {
  background-color: #eeeff4;
}
.notification_list:hover {
  background-color: #f8f9fb;
}
.notification_list:last-child {
  border-bottom: none;
}
.notification_list:after{
  content: "";
  clear: both;
  display: block;
}
.notification_list .notification_list_cover{
  position: absolute;
  opacity: 0;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1;

}
.notification_list .list_image {
  float: left;
  width: 40px;
  height: 40px;
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
  background-color: #979797;
}
.notification_list .list_text_wrapper {
  float: left;
  width: calc(100% - 60px);
  margin-left: 20px;
}
.notification_list .list_text_wrapper .list_text {
  color: #4f4f4f;
  font-size: 14px;
  line-height: 1.4;
  margin-top: 0;
  height: auto;
  font-weight: normal;
}
.notification_list .list_text_wrapper .list_text span {
  color: #4f4f4f;
  font-size: 14px;
}
.notification_list .list_text_wrapper .list_text strong{
  font-weight: bold;
}
.notification_list .list_text_wrapper .list_text span.created_at {
  color: #979797;
  font-size: 13px;
}
</style>