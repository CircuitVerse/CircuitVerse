import { defineStore } from 'pinia'
import { useState } from './state'

export const useActions = defineStore('simulatorStore.actions', () => {
    const state = useState()

    function showTitle(): void {
    }

    function showMessage(message: string, type: 'error' | 'success') {
        if (type === 'error') {
            state.errorMessages.push(message)
        } else {
            state.successMessages.push(message)
        }

        setTimeout(() => {
            if (type === 'error') {
                state.errorMessages.shift()
            } else {
                state.successMessages.shift()
            }
        }, type === 'error' ? 1500 : 2500)
    }

    // Note you are free to define as many internal functions as you want.
    // You only expose the functions that are returned.
    return {
        showTitle,
        showMessage,
    }
})
