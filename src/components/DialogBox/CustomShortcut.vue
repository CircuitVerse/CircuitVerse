<template>
    <v-dialog
        v-model="SimulatorState.dialogBox.customshortcut_dialog"
        :persistent="false"
        @click:outside="closeDialog()"
    >
        <v-card class="customShortcutBox">
            <v-card-text>
                <p class="dialogHeader">
                    {{ $t('simulator.panel_header.keybinding_preference') }}
                </p>
                <v-btn
                    size="x-small"
                    icon
                    class="dialogClose"
                    @click="closeAllDialog()"
                >
                    <v-icon>mdi-close</v-icon>
                </v-btn>
                <div id="customShortcutDialog" title="Keybinding Preference">
                    <!-- Edit Panel -->
                    <div id="edit" tabindex="0" @keydown="updateEdit($event)">
                        <span style="font-size: 14px">
                            {{
                                $t(
                                    'simulator.panel_body.custom_shortcut.esc_cancel'
                                )
                            }}
                        </span>
                        <v-btn
                            size="x-small"
                            icon
                            class="dialogClose"
                            @click.prevent="closeDialog()"
                        >
                            <v-icon>mdi-close</v-icon>
                        </v-btn>
                        <div id="pressedKeys">{{ pressedKeys }}</div>
                        <div id="warning">{{ warning }}</div>
                    </div>
                    <!-- Heading -->
                    <div id="heading">
                        <span>{{
                            $t('simulator.panel_body.custom_shortcut.command')
                        }}</span>
                        <span>{{
                            $t(
                                'simulator.panel_body.custom_shortcut.keymapping'
                            )
                        }}</span>
                    </div>
                    <!-- Markup -->
                    <div
                        id="preference"
                        class="customScroll"
                        @click="updatePreference($event)"
                    >
                        <!-- Elements -->
                        <div
                            v-for="(keyOption, index) in keyOptions"
                            :key="index"
                        >
                            <span id="edit-icon"></span>
                            <div>
                                <span id="command">{{ keyOption[0] }}</span>
                                <span id="keyword"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </v-card-text>
            <v-card-actions>
                <v-btn class="messageBtn" block @click="resetKeybinding()">
                    {{
                        $t(
                            'simulator.panel_body.custom_shortcut.reset_to_default'
                        )
                    }}
                </v-btn>
                <v-btn class="messageBtn" block @click="saveKeybinding()">
                    {{ $t('simulator.panel_body.custom_shortcut.save') }}
                </v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts">
import { defaultKeys } from '#/simulator/src/hotkey_binder/defaultKeys'
import {
    addKeys,
    checkUpdate,
    setDefault,
    warnOverride,
} from '#/simulator/src/hotkey_binder/model/actions'
import { KeyCode } from '#/simulator/src/hotkey_binder/model/normalize/normalizer.plugin'
import { checkRestricted } from '#/simulator/src/hotkey_binder/model/utils'
import {
    closeEdit,
    override,
    submit,
    updateHTML,
} from '#/simulator/src/hotkey_binder/view/panel.ui'
import { useState } from '#/store/SimulatorStore/state'
import { onMounted, onUpdated, ref, Ref } from '@vue/runtime-core'
import { confirmOption } from '../helpers/confirmComponent/ConfirmComponent.vue'

export function keyBinder() {
    const SimulatorState = useState()
    SimulatorState.dialogBox.customshortcut_dialog = true
}
</script>

<script lang="ts" setup>
interface KeyOption {
    0: string
    1: string
}

const SimulatorState = useState()
const keyOptions = ref<KeyOption[]>([])
const targetPref = ref<HTMLSpanElement | null>(null)
const pressedKeys: Ref<string> = ref('')
const warning: Ref<string> = ref('')

onMounted(() => {
    if (localStorage.userKeys) {
        checkUpdate()
        addKeys('user')
    } else setDefault()
    SimulatorState.dialogBox.customshortcut_dialog = false
    keyOptions.value = Object.entries(defaultKeys) as KeyOption[]
})

onUpdated(() => {
    if (localStorage.userKeys) {
        checkUpdate()
        addKeys('user')
    } else {
        setDefault()
    }
})

function updatePreference(e: MouseEvent) {
    pressedKeys.value = ''
    warning.value = ''
    document.getElementById('edit')!.style.border = 'none'
    document.getElementById('edit')!.style.display = 'block'
    document.getElementById('edit')!.focus()
    ;[, targetPref.value] = e.target!.closest('div')!.children as [
        HTMLSpanElement,
        HTMLSpanElement
    ]
}

function updateEdit(e: KeyboardEvent) {
    e = e || window.event!
    e.stopPropagation()
    e.preventDefault()
    const k = KeyCode
    let modifiers = ['CTRL', 'ALT', 'SHIFT', 'META']
    document.getElementById('edit')!.style.animation = 'none'
    warning.value = ''
    if (e.keyCode === 27) closeEdit()
    if (e.keyCode === 13) {
        if (pressedKeys.value === '') {
            warning.value = 'Please enter some key(s)'
            document.getElementById('edit')!.style.animation =
                'shake .3s linear'
            return
        }

        if (!checkRestricted(pressedKeys.value)) {
            override(pressedKeys.value)
            targetPref.value!.innerText = pressedKeys.value
            pressedKeys.value = ''
            document.getElementById('edit')!.style.display = 'none'
        } else {
            warning.value = 'Please enter different key(s).'
            document.getElementById('edit')!.style.animation =
                'shake .3s linear'
            pressedKeys.value = ''
            return
        }
    }
    const currentKey =
        k.hot_key(k.translate_event(e)).split('+').join(' + ') !== 'Enter'
            ? k.hot_key(k.translate_event(e)).split('+').join(' + ')
            : ''
    if (
        pressedKeys.value.split(' + ').length === 2 &&
        !modifiers.includes(currentKey) &&
        modifiers.includes(pressedKeys.value.split(' + ')[1])
    ) {
        pressedKeys.value += `+ ${currentKey}`
    } else if (modifiers.includes(pressedKeys.value)) {
        modifiers = modifiers.filter((mod) => mod === pressedKeys.value)
        if (!modifiers.includes(currentKey)) {
            pressedKeys.value += `+ ${currentKey}`
        }
    } else {
        pressedKeys.value = ''
        pressedKeys.value = currentKey
    }
    if (!pressedKeys.value) {
        pressedKeys.value = currentKey
    }
    if (
        (pressedKeys.value.split(' + ').length === 2 &&
            ['Ctrl', 'Meta'].includes(pressedKeys.value.split(' + ')[1])) ||
        (pressedKeys.value.split(' + ')[0] === 'Alt' &&
            pressedKeys.value.split(' + ')[1] === 'Shift')
    ) {
        pressedKeys.value = pressedKeys.value.split(' + ').reverse().join(' + ')
    }

    warnOverride(pressedKeys.value, targetPref.value!, warning)
    if (checkRestricted(pressedKeys.value)) {
        warning.value =
            'The above combination is a system default shortcut & cannot be set.'
    }
}

async function resetKeybinding() {
    if (await confirmOption('Remove all custom keys & set the default keys?'))
        setDefault()
}

function saveKeybinding() {
    submit()
    SimulatorState.dialogBox.customshortcut_dialog = false
}

function closeDialog() {
    const editDialogState = document.getElementById('edit')!.style.display
    if (editDialogState === 'block') {
        document.getElementById('edit')!.style.display = 'none'
    }
}

function closeAllDialog() {
    const editDialogState = document.getElementById('edit')!.style.display
    if (editDialogState === 'block') {
        document.getElementById('edit')!.style.display = 'none'
    }
    if (localStorage.userKeys) {
        updateHTML('user')
    } else {
        updateHTML('default')
    }
    SimulatorState.dialogBox.customshortcut_dialog = false
}
</script>

<style scoped>
.customShortcutBox {
    height: auto;
    width: 660px;
    justify-content: center;
    margin: auto;
    backdrop-filter: blur(5px);
    border-radius: 5px;
    border: 0.5px solid var(--br-primary) !important;
    background: var(--bg-primary-moz) !important;
    background-color: var(--bg-primary-chr) !important;
    color: white;
}

/* media query for .customShortcutBox */
@media screen and (max-width: 991px) {
    .customShortcutBox {
        width: 100%;
    }
}
</style>
