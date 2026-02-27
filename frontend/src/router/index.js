import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@src/views/HomeView.vue'),
    },
    {
      path: '/room/:roomId',
      name: 'room',
      component: () => import('@src/views/RoomView.vue'),
    },
  ],
})

export default router
