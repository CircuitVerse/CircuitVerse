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
            console.log('Hello From Context Menu' + id)
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

// /* // Cant procced with logic sice Canvas Area Compoennet is nor defined yet.
// Plan :- // 1. To have a data property : showContextMenu : false // 2. This
will be passed to Paretn Component( Simulator ) // 3. From Simulator will be
passed down to Cnavas Area Compoent // 4. In Canavs Area will check for //
document.getElementById('canvasArea').oncontextmenu = showContextMenu; // then
make showContextMenu : true // 5. In this ContextMenu file will check for the
state showContextMenu to call the // function showContextMenu() which is in
ux.js // 6. In siluator Parent component will check for a click in any component
except context menu // It will make make showContextMenu : false // and will
stop displaying the context menu // */
