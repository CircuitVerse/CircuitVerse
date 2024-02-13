<template>
    <div id="text-editor" :class="{ fullscreen: fullscreen }">
        <div v-if="editor" class="toolbar">
            <div class="align-dropdown">
                <button class="dropbtn" @click.prevent="">Heading ▼</button>
                <div class="dropdown-content">
                    <a
                        v-for="index in 6"
                        :key="index"
                        :class="{
                            active: editor.isActive('heading', {
                                level: index,
                            }),
                        }"
                        :style="{
                            fontSize: 20 - index + 'px',
                            backgroundColor: '#555',
                        }"
                        role="button"
                        @click.prevent="onHeadingClick(index)"
                    >
                        H{{ index }}
                    </a>
                </div>
            </div>

            <button
                v-for="({ slug, option, active, icon }, index) in textActions"
                :key="index"
                :class="{ active: editor.isActive(active) }"
                @click.prevent="onActionClick(slug, option)"
            >
                <i :class="icon"></i>
            </button>

            <div class="mode-toggle">
                <button
                    :class="{ active: showSourceCode }"
                    @click.prevent="toggleMode"
                >
                    <i class="fas fa-file-code"></i>
                </button>
                <button
                    :class="{ active: fullscreen }"
                    @click.prevent="toggleFullscreen"
                >
                    <i v-if="!fullscreen" class="fas fa-expand-arrows-alt"></i>
                    <i v-else class="fas fa-compress-arrows-alt"></i>
                </button>
            </div>
        </div>

        <div v-if="showSourceCode">
            <textarea
                v-model="sourceCode"
                style="
                    width: 100%;
                    height: 13.85rem;
                    color: #fff;
                    padding: 1rem;
                    outline: none;
                "
            ></textarea>
        </div>
        <editor-content v-else class="editor" :editor="editor" />

        <div v-if="editor && !showSourceCode" class="footer">
            <span
                class="characters-count"
                :class="maxLimit ? limitWarning : ''"
            >
                {{ charactersCount }}
                {{ maxLimit ? `/ ${maxLimit} characters` : 'characters' }}
            </span>
            |
            <span class="words-count"> {{ wordsCount }} words </span>
        </div>
    </div>
</template>

<script>
import { Editor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import TextAlign from '@tiptap/extension-text-align'
import Underline from '@tiptap/extension-underline'
import Subscript from '@tiptap/extension-subscript'
import Superscript from '@tiptap/extension-superscript'
import CharacterCount from '@tiptap/extension-character-count'

export default {
    components: {
        EditorContent,
    },
    props: {
        modelValue: {
            type: String,
            default: '',
        },
        maxLimit: {
            type: Number,
            default: null,
        },
    },
    emits: ['toggleFullscreen', 'update:modelValue'],
    data() {
        return {
            editor: null,
            showSourceCode: false,
            sourceCode: '',
            fullscreen: false,
            textActions: [
                { slug: 'bold', icon: 'fas fa-bold', active: 'bold' },
                { slug: 'italic', icon: 'fas fa-italic', active: 'italic' },
                {
                    slug: 'underline',
                    icon: 'fas fa-underline',
                    active: 'underline',
                },
                {
                    slug: 'strike',
                    icon: 'fas fa-strikethrough',
                    active: 'strike',
                },
                {
                    slug: 'align',
                    option: 'left',
                    icon: 'fas fa-align-left',
                    active: { textAlign: 'left' },
                },
                {
                    slug: 'align',
                    option: 'center',
                    icon: 'fas fa-align-center',
                    active: { textAlign: 'center' },
                },
                {
                    slug: 'align',
                    option: 'right',
                    icon: 'fas fa-align-right',
                    active: { textAlign: 'right' },
                },
                {
                    slug: 'align',
                    option: 'justify',
                    icon: 'fas fa-align-justify',
                    active: { textAlign: 'justify' },
                },
                {
                    slug: 'bulletList',
                    icon: 'fas fa-list-ul',
                    active: 'bulletList',
                },
                {
                    slug: 'orderedList',
                    icon: 'fas fa-list-ol',
                    active: 'orderedList',
                },
                {
                    slug: 'subscript',
                    icon: 'fas fa-subscript',
                    active: 'subscript',
                },
                {
                    slug: 'superscript',
                    icon: 'fas fa-superscript',
                    active: 'superscript',
                },
                { slug: 'undo', icon: 'fas fa-undo', active: 'undo' },
                { slug: 'redo', icon: 'fas fa-redo', active: 'redo' },
                { slug: 'clear', icon: 'fas fa-times-circle', active: 'clear' },
            ],
        }
    },
    computed: {
        charactersCount() {
            return this.editor.storage.characterCount.characters()
        },
        wordsCount() {
            return this.editor.storage.characterCount.words()
        },
        limitWarning() {
            const isCloseToMax = this.charactersCount >= this.maxLimit - 20
            const isMax = this.charactersCount === this.maxLimit

            if (isCloseToMax && !isMax) return 'warning'
            if (isMax) return 'danger'

            return ''
        },
    },
    watch: {
        modelValue(value) {
            if (this.showSourceCode) {
                this.sourceCode = value
            } else if (this.editor.getHTML() !== value) {
                this.editor.commands.setContent(value, false)
            }
        },
        showSourceCode(value) {
            if (value) {
                this.sourceCode = this.editor.getHTML()
            } else {
                this.editor.commands.setContent(this.sourceCode, false)
            }
        },
    },
    mounted() {
        this.editor = new Editor({
            content: this.modelValue,
            extensions: [
                StarterKit,
                Underline,
                Subscript,
                Superscript,
                CharacterCount.configure({
                    limit: this.maxLimit,
                }),
                TextAlign.configure({
                    types: ['heading', 'paragraph'],
                }),
            ],
            onUpdate: () => {
                this.$emit('update:modelValue', this.editor.getHTML())
            },
        })
        document.addEventListener(
            'fullscreenchange',
            this.handleFullscreenChange
        )
    },
    beforeUnmount() {
        this.editor.destroy()
        document.removeEventListener(
            'fullscreenchange',
            this.handleFullscreenChange
        )
    },
    methods: {
        onActionClick(slug, option = null) {
            if (this.showSourceCode) return
            const vm = this.editor.chain().focus()
            const actionTriggers = {
                bold: () => vm.toggleBold().run(),
                italic: () => vm.toggleItalic().run(),
                underline: () => vm.toggleUnderline().run(),
                strike: () => vm.toggleStrike().run(),
                bulletList: () => vm.toggleBulletList().run(),
                orderedList: () => vm.toggleOrderedList().run(),
                align: () => vm.setTextAlign(option).run(),
                subscript: () => vm.toggleSubscript().run(),
                superscript: () => vm.toggleSuperscript().run(),
                undo: () => vm.undo().run(),
                redo: () => vm.redo().run(),
                clear: () => {
                    vm.clearNodes().run()
                    vm.unsetAllMarks().run()
                },
            }

            actionTriggers[slug]()
        },
        onHeadingClick(index) {
            if (this.showSourceCode) return
            const vm = this.editor.chain().focus()
            vm.toggleHeading({ level: index }).run()
        },
        toggleMode() {
            if (this.fullscreen) return
            this.showSourceCode = !this.showSourceCode
        },
        toggleFullscreen() {
            if (this.showSourceCode) return
            this.fullscreen = !this.fullscreen
            this.$emit('toggleFullscreen')
            if (this.fullscreen) {
                document.documentElement.requestFullscreen()
            } else {
                document.exitFullscreen()
            }
        },
        handleFullscreenChange() {
            if (this.showSourceCode) return
            this.fullscreen = document.fullscreenElement !== null
        },
    },
}
</script>

<style scoped>
.editor {
    margin: 0.5rem;
}

.fullscreen {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 9999;
    background-color: #444;
}

#text-editor {
    border: 1px solid #808080;
    border-radius: 4px;
    height: auto;
}

#text-editor .toolbar {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    border-bottom: 1px solid #808080;
}

#text-editor .toolbar > button {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    font-size: 20px;
    background: #555;
    color: #fff;
    border: none;
    border-radius: 2px;
    margin: 0.5em 4px;
    -webkit-appearance: none;
    appearance: none;
    cursor: pointer;
}

#text-editor .toolbar > button.active {
    background: #333;
    color: #fff;
}

#text-editor .align-dropdown {
    position: relative;
    display: inline-block;
    margin: 0.5em 8px;
}

#text-editor .align-dropdown > button {
    height: 32px;
    background: #555;
    color: #fff;
    border: none;
    border-radius: 2px;
    -webkit-appearance: none;
    appearance: none;
    cursor: pointer;
}

#text-editor .align-dropdown > .dropdown-content {
    display: none;
    position: absolute;
    left: 0;
    right: 0;
    border: 1px solid #333;
    outline: 1px solid #fff;
    border-radius: 2px;
    background-color: #fff;
    z-index: 1;
}

#text-editor .align-dropdown > .dropdown-content a {
    display: block;
    padding: 6px 12px;
    text-align: center;
    cursor: pointer;
}

#text-editor .align-dropdown > .dropdown-content a:hover,
#text-editor .align-dropdown > .dropdown-content a.active {
    background: #333;
    color: #fff;
}

#text-editor .align-dropdown:hover .dropdown-content {
    display: block;
}

#text-editor .divider {
    width: 1px;
    height: 24px;
    background: #333;
    margin-right: 6px;
}

#text-editor .footer {
    color: #aaa;
    font-size: 14px;
    text-align: right;
    padding: 6px;
}

#text-editor .footer .characters-count {
    color: #aaa;
}

#text-editor .footer .characters-count.warning {
    color: orange;
}

#text-editor .footer .characters-count.danger {
    color: red;
}

#text-editor .ProseMirror {
    height: 12rem;
    overflow-y: auto;
    padding-left: 0.5em;
    padding-right: 0.5em;
    outline: none;
}

#text-editor .toolbar > .mode-toggle {
    display: flex;
    margin-left: auto;
}

#text-editor .toolbar > .mode-toggle > button {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    font-size: 20px;
    background: #555;
    color: #fff;
    border: none;
    border-radius: 2px;
    margin: 0.5em 4px;
    -webkit-appearance: none;
    appearance: none;
    cursor: pointer;
}

#text-editor .toolbar > .mode-toggle > button.active {
    background: #333;
    color: #fff;
}
</style>
