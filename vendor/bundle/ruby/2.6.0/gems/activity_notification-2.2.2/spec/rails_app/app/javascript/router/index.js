import Vue from 'vue'
import VueRouter from 'vue-router'
import store from '../store'
import DeviseTokenAuth from '../components/DeviseTokenAuth.vue'
import Top from '../components/Top.vue'
import NotificationsIndex from '../components/notifications/Index.vue'
import SubscriptionsIndex from '../components/subscriptions/Index.vue'

Vue.use(VueRouter)

const routes = [
  // Routes for common components
  { path: '/', component: Top },
  { path: '/login', component: DeviseTokenAuth },
  { path: '/logout', component: DeviseTokenAuth, props: { isLogout: true } },
  // Routes for single page application working with activity_notification REST API backend for users
  {
    path: '/notifications',
    name: 'AuthenticatedUserNotificationsIndex',
    component: NotificationsIndex,
    props: () => ({ target_type: 'users', target: store.getters.currentUser }),
    meta: { requiresAuth: true }
  },
  {
    path: '/subscriptions',
    name: 'AuthenticatedUserSubscriptionsIndex',
    component: SubscriptionsIndex,
    props: () => ({ target_type: 'users', target: store.getters.currentUser }),
    meta: { requiresAuth: true }
  },
  // Routes for single page application working with activity_notification REST API backend for admins
  {
    path: '/admins/notifications',
    name: 'AuthenticatedAdminNotificationsIndex',
    component: NotificationsIndex,
    props: () => ({ target_type: 'admins', targetApiPath: 'admins', target: store.getters.currentUser.admin }),
    meta: { requiresAuth: true }
  },
  {
    path: '/admins/subscriptions',
    name: 'AuthenticatedAdminSubscriptionsIndex',
    component: SubscriptionsIndex,
    props: () => ({ target_type: 'admins', targetApiPath: 'admins', target: store.getters.currentUser.admin }),
    meta: { requiresAuth: true }
  },
  // Routes for single page application working with activity_notification REST API backend for unauthenticated targets
  {
    path: '/:target_type/:target_id/notifications',
    name: 'UnauthenticatedTargetNotificationsIndex',
    component: NotificationsIndex,
    props : true
  },
  {
    path: '/:target_type/:target_id/subscriptions',
    name: 'UnauthenticatedTargetSubscriptionsIndex',
    component: SubscriptionsIndex,
    props : true
  }
]

const router = new VueRouter({
  routes
})

router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth) && !store.getters.userSignedIn) {
      next({ path: '/login', query: { redirect: to.fullPath }});
  } else {
    next();
  }
})

export default router
