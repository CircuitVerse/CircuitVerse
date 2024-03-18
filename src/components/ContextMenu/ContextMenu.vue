<template>
    <div id="contextMenu" oncontextmenu="return false;">
        <ul>
            <li
                v-for="(menuOption, index) in contextMenuOptions"
                :key="index"
                :data-index="index"
                @click="menuItemClicked($event)"
            >
                {{ menuOption }}
            </li>
        </ul>
    </div>
</template>

<script>
import undo from '../../simulator/src/data/undo'
import { paste } from '../../simulator/src/events'
import { deleteSelected } from '../../simulator/src/ux'
import { createNewCircuitScope } from '../../simulator/src/circuit'
import logixFunction from '../../simulator/src/data'

export default {
    name: 'ContextMenu',
    data() {
        return {
            contextMenuOptions: [
                'Copy',
                'Cut',
                'Paste',
                'Delete',
                'Undo',
                'New Circuit',
                'Insert Subcircuit',
                'Center Focus',
            ],
            ctxPos: {
                x: 0,
                y: 0,
                visible: false,
            },
        }
    },

    // Lifecycle hook on mounted - dont initially display the context menu
    mounted() {
        this.hideContextMenu()
    },
    methods: {
        hideContextMenu() {
            var el = document.getElementById('contextMenu')
            el.style = 'opacity:0;'
            setTimeout(() => {
                el.style = 'visibility:hidden;'
                this.ctxPos.visible = false
            }, 200) // Hide after 2 sec
        },
        menuItemClicked(event) {
            this.hideContextMenu()
            const id = event.target.dataset.index
            if (id == 0) {
                document.execCommand('copy')
            } else if (id == 1) {
                document.execCommand('cut')
            } else if (id == 2) {
                // document.execCommand('paste'); it is restricted to sove this problem we use dataPasted variable
                paste(localStorage.getItem('clipboardData'))
            } else if (id == 3) {
                deleteSelected()
            } else if (id == 4) {
                undo()
            } else if (id == 5) {
                createNewCircuitScope()
            } else if (id == 6) {
                logixFunction.createSubCircuitPrompt()
            } else if (id == 7) {
                globalScope.centerFocus(false)
            }
        },
    },
}
</script>
