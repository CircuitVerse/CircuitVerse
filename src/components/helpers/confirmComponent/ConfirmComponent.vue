<template>
    <messageBox
        v-model="promptStore.confirm.activate"
        :messageText="promptStore.confirm.messageText"
        :isPersistent="promptStore.confirm.isPersistent"
        :buttonList="promptStore.confirm.buttonList"
        @buttonClick="(selectedOption) => confirmation(selectedOption)"
    />
</template>

<script lang="ts">
import messageBox from '#/components/MessageBox/messageBox.vue'
import { usePromptStore } from '#/store/promptStore'

function clearMessageBoxFields(): void {
    const promptStore = usePromptStore()

    promptStore.confirm.activate = false
    promptStore.confirm.isPersistent = false
    promptStore.confirm.messageText = ''
    promptStore.confirm.buttonList = []
}

const promptActivator = async (
    messageText: string,
    buttonList: Array<{ text: string; emitOption: string | boolean }>
): Promise<string | boolean> => {
    clearMessageBoxFields()
    const promptStore = usePromptStore()
    promptStore.confirm.activate = true
    promptStore.confirm.isPersistent = true
    promptStore.confirm.messageText = messageText
    promptStore.confirm.buttonList = buttonList

    const promptInput = await new Promise<string | boolean>((resolve) => {
        promptStore.resolvePromise = resolve
    })

    return promptInput
}

export const confirmOption = async (
    messageText: string = 'confirm'
): Promise<string | boolean> => {
    const buttonList: Array<{ text: string; emitOption: boolean }> = [
        { text: 'Cancel', emitOption: false },
        { text: 'Ok', emitOption: true },
    ]

    const confirmation = await promptActivator(messageText, buttonList)

    return confirmation
}

export const confirmMultiOption = async (
    messageText: string = 'confirm',
    buttonArray: Array<string>
): Promise<string | boolean> => {
    const buttonList: Array<{ text: string; emitOption: string }> = []
    buttonArray.forEach((element) => {
        buttonList.push({ text: element, emitOption: element })
    })

    const confirmation = await promptActivator(messageText, buttonList)

    return confirmation
}

export const confirmSingleOption = async (
    messageText: string = 'confirm'
): Promise<string | boolean> => {
    const buttonList: Array<{ text: string; emitOption: boolean }> = [
        { text: 'Ok', emitOption: true },
    ]

    const confirmation = await promptActivator(messageText, buttonList)

    return confirmation
}
</script>

<script lang="ts" setup>
const promptStore = usePromptStore()

const confirmation = (selectedOption: string | boolean): void => {
    promptStore.confirm.activate = false
    for (const button of promptStore.confirm.buttonList) {
        if (button.emitOption == selectedOption) {
            promptStore.resolvePromise(button.emitOption)
        }
    }
}
</script>
