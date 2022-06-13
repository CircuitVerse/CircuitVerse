import { defineStore } from "pinia";
import { computed } from 'vue'
import { useState } from './state'

export const useGetters = defineStore('simulatorStore.getters', () => {
  const state = useState()

  const getTitle = computed((): string => {
    return `${state.title} !!!`;
  })

  return {
    getTitle
  }
})