<template>
    <messageBox
        v-model="promptStore.prompt.activate"
        :messageText="promptStore.prompt.messageText"
        :isPersistent="promptStore.prompt.isPersistent"
        :buttonList="promptStore.prompt.buttonList"
        :inputList="promptStore.prompt.inputList"
        :input-class="inputClass"
        @buttonClick="(selectedOption) => confirmation(selectedOption)"
    />
</template>

<script lang="ts">
import messageBox from '#/components/MessageBox/messageBox.vue'
import { usePromptStore } from '#/store/promptStore'
import { ref } from 'vue'

interface ButtonListType
    extends Array<{
        text: string
        emitOption: 'cancel' | 'save'
    }> {}

interface InputListType
    extends Array<{
        text: string
        val: string
        class: string
        style: string
        id: string
        type: string
        placeholder: string
    }> {}

const inputClass = ref('')

function clearMessageBoxFields(): void {
    const promptStore = usePromptStore()

    promptStore.prompt.activate = false
    promptStore.prompt.isPersistent = false
    promptStore.prompt.messageText = ''
    promptStore.prompt.buttonList = []
    promptStore.prompt.inputList = []
}

const promptActivator = async (
    messageText: string,
    buttonList: ButtonListType,
    inputList: InputListType
): Promise<string | Error> => {
    clearMessageBoxFields()
    const promptStore = usePromptStore()
    promptStore.prompt.activate = true
    promptStore.prompt.isPersistent = true
    promptStore.prompt.messageText = messageText
    promptStore.prompt.buttonList = buttonList
    promptStore.prompt.inputList = inputList

    const promptInput = await new Promise<string | Error>((resolve) => {
        promptStore.resolvePromise = resolve
    })

    return promptInput
}

export const provideProjectName = async (): Promise<string | Error> => {
    inputClass.value = 'project-name-input'
    const messageText = ''

    const buttonList: ButtonListType = [
        {
            text: 'Save',
            emitOption: 'save',
        },
        {
            text: 'Cancel',
            emitOption: 'cancel',
        },
    ]

    const inputList: InputListType = [
        {
            text: 'Enter Project Name:',
            val: '',
            placeholder: 'Untitled',
            id: 'projectName',
            class: 'inputField',
            style: '',
            type: 'text',
        },
    ]

    const projectName = await promptActivator(
        messageText,
        buttonList,
        inputList
    )

    return projectName
}

export const provideCircuitName = async (): Promise<string | Error> => {
    inputClass.value = 'circuit-name-input'
    const messageText = ''

    const buttonList: ButtonListType = [
        {
            text: 'Create',
            emitOption: 'save',
        },
        {
            text: 'Cancel',
            emitOption: 'cancel',
        },
    ]

    const inputList: InputListType = [
        {
            text: 'Enter Circuit Name:',
            val: '',
            placeholder: 'Untitled-circuit',
            id: 'circuitName',
            class: 'inputField',
            style: '',
            type: 'text',
        },
    ]

    const circuitName = await promptActivator(
        messageText,
        buttonList,
        inputList
    )

    return circuitName
}
</script>

<script lang="ts" setup>
const promptStore = usePromptStore()

const confirmation = (selectedOption: string): void => {
    promptStore.prompt.activate = false
    if (selectedOption === 'save') {
        promptStore.resolvePromise(promptStore.prompt.inputList[0].val)
    } else {
        promptStore.resolvePromise(new Error('cancel'))
    }
}
</script>
