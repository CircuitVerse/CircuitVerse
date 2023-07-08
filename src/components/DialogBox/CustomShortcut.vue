<template>
    <v-dialog
        v-model="SimulatorState.dialogBox.customshortcut_dialog"
        :persistent="false"
    >
        <v-card class="messageBoxContent">
            <v-card-text>
                <p class="dialogHeader">Keybinding Preference</p>
                <v-btn
                    size="x-small"
                    icon
                    class="dialogClose"
                    @click="closeDialog()"
                >
                    <v-icon>mdi-close</v-icon>
                </v-btn>
                <div id="customShortcutDialog" title="Keybinding Preference">
                    <!-- Edit Panel -->
                    <div id="edit" tabindex="0" @keydown="updateEdit($event)">
                        <span style="font-size: 14px">
                            Press Desire Key Combination & press Enter or press
                            ESC to cancel.
                        </span>
                        <div id="pressedKeys"></div>
                        <div id="warning"></div>
                    </div>
                    <!-- Heading -->
                    <div id="heading">
                        <span>Command</span>
                        <span>Keymapping</span>
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
                    Reset To Default
                </v-btn>
                <v-btn class="messageBtn" block @click="saveKeybinding()">
                    Save
                </v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts" setup>
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
import { onMounted, onUpdated, ref } from '@vue/runtime-core'
import { confirmOption } from '../helpers/confirmComponent/ConfirmComponent.vue'
const SimulatorState = useState()
const keyOptions = ref([])
const targetPref = ref(null)

onMounted(() => {
    SimulatorState.dialogBox.customshortcut_dialog = false
    keyOptions.value = Object.entries(defaultKeys)
})

onUpdated(() => {
    if (localStorage.userKeys) {
        checkUpdate()
        addKeys('user')
    } else setDefault()
})

function updatePreference(e) {
    $('#pressedKeys').text('')
    $('#warning').text('')
    $('#edit').css('border', 'none')
    $('#edit').css('display', 'block')
    $($('#edit')).focus()
    ;[, targetPref.value] = e.target.closest('div').children
}

function updateEdit(e) {
    e = e || window.event
    e.stopPropagation()
    e.preventDefault()
    var k = KeyCode
    let modifiers = ['CTRL', 'ALT', 'SHIFT', 'META']
    $('#edit').css('animation', 'none')
    $('#warning').text('')
    if (e.keyCode === 27) closeEdit()
    if (e.keyCode === 13) {
        if ($('#pressedKeys').text() === '') {
            $('#warning').text('Please enter some key(s)')
            $('#edit').css('animation', 'shake .3s linear')
            return
        }

        if (!checkRestricted($('#pressedKeys').text())) {
            override($('#pressedKeys').text())
            targetPref.value.innerText = $('#pressedKeys').text()
            $('#pressedKeys').text('')
            $('#edit').css('display', 'none')
        } else {
            $('#warning').text('Please enter different key(s).')
            $('#edit').css('animation', 'shake .3s linear')
            $('#pressedKeys').text('')
        }
    }
    const currentKey =
        k.hot_key(k.translate_event(e)).split('+').join(' + ') !== 'Enter'
            ? k.hot_key(k.translate_event(e)).split('+').join(' + ')
            : ''
    if (
        $('#pressedKeys').text().split(' + ').length === 2 &&
        !modifiers.includes(currentKey) &&
        modifiers.includes($('#pressedKeys').text().split(' + ')[1])
    ) {
        $('#pressedKeys').append(` + ${currentKey}`)
    } else if (modifiers.includes($('#pressedKeys').text())) {
        modifiers = modifiers.filter((mod) => mod === $('#pressedKeys').text())
        if (!modifiers.includes(currentKey)) {
            $('#pressedKeys').append(` + ${currentKey}`)
        }
    } else {
        $('#pressedKeys').text('')
        $('#pressedKeys').text(currentKey)
    }
    if (!$('#pressedKeys').text()) {
        $('#pressedKeys').text(currentKey)
    }
    if (
        ($('#pressedKeys').text().split(' + ').length === 2 &&
            ['Ctrl', 'Meta'].includes(
                $('#pressedKeys').text().split(' + ')[1]
            )) ||
        ($('#pressedKeys').text().split(' + ')[0] === 'Alt' &&
            $('#pressedKeys').text().split(' + ')[1] === 'Shift')
    ) {
        $('#pressedKeys').text(
            $('#pressedKeys').text().split(' + ').reverse().join(' + ')
        )
    }

    warnOverride($('#pressedKeys').text(), targetPref.value)
    if (checkRestricted($('#pressedKeys').text())) {
        $('#warning').text(
            'The above combination is a system default shortcut & cannot be set.'
        )
    }
}

async function resetKeybinding() {
    console.log('Reset Keybinding')
    if (await confirmOption('Remove all custom keys & set the default keys?'))
        setDefault()
}

function saveKeybinding() {
    console.log('Save Keybinding')
    submit()
    SimulatorState.dialogBox.customshortcut_dialog = false
}
function closeDialog() {
    if (localStorage.userKeys) {
        updateHTML('user')
    } else updateHTML('default')
    SimulatorState.dialogBox.customshortcut_dialog = false
}
</script>
