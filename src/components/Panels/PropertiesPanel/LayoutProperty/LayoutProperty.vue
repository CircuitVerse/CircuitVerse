<template>
    <div id="layoutDialog" class="draggable-panel draggable-panel-css">
        <div class="panel-header">
            Layout
            <span class="fas fa-minus-square minimize"></span>
            <span class="fas fa-external-link-square-alt maximize"></span>
        </div>
        <div id="layout-body" class="layout-body panel-body">
            <div class="">
                <button
                    id="decreaseLayoutWidth"
                    class="zoomButton btn-lg"
                    title="Decrease Width"
                >
                    <span class="fa fa-minus" aria-hidden="true"></span>
                </button>
                <span>Width</span>
                <button
                    id="increaseLayoutWidth"
                    class="zoomButton btn-lg"
                    title="Increase Width"
                >
                    <span class="fa fa-plus" aria-hidden="true"></span>
                </button>
            </div>
            <div class="">
                <button
                    id="decreaseLayoutHeight"
                    class="zoomButton btn-lg"
                    title="Decrease Height"
                >
                    <span class="fa fa-minus" aria-hidden="true"></span>
                </button>
                <span>Height</span>
                <button
                    id="increaseLayoutHeight"
                    class="zoomButton btn-lg"
                    title="Increase Height"
                >
                    <span class="fa fa-plus" aria-hidden="true"></span>
                </button>
            </div>
            <div class="">
                <span>Reset all nodes:</span>
                <button id="layoutResetNodes" class="zoomButton btn-lg">
                    <span
                        class="fa fa-sync"
                        aria-hidden="true"
                        title="Reset"
                    ></span>
                </button>
            </div>
            <div class="layout-title">
                <span>Title</span>
                <div class="layout--btn-group">
                    <button
                        id="layoutTitleUp"
                        class="zoomButton-up btn-lg no-select"
                    >
                        <svg
                            id="Group_304"
                            data-name="Group 304"
                            xmlns="http://www.w3.org/2000/svg"
                            width="30"
                            height="30"
                            viewBox="0 0 30 30"
                        >
                            <g
                                id="Rectangle_1072"
                                data-name="Rectangle 1072"
                                fill="none"
                                stroke="#f1f9ff"
                                stroke-width="2"
                            >
                                <rect
                                    width="30"
                                    height="30"
                                    rx="10"
                                    stroke="none"
                                />
                                <rect
                                    x="1"
                                    y="1"
                                    width="28"
                                    height="28"
                                    rx="9"
                                    fill="none"
                                />
                            </g>
                            <path
                                id="Path_36"
                                data-name="Path 36"
                                d="M4.7,6.1,0,1.4,1.4,0,4.7,3.3,8,0,9.4,1.4Z"
                                transform="translate(19.4 17.755) rotate(180)"
                                fill="#fff"
                            />
                        </svg>
                    </button>
                    <button
                        id="layoutTitleDown"
                        class="zoomButton-down btn-lg no-select"
                    >
                        <svg
                            id="Group_305"
                            data-name="Group 305"
                            xmlns="http://www.w3.org/2000/svg"
                            width="30"
                            height="30"
                            viewBox="0 0 30 30"
                        >
                            <g
                                id="Rectangle_1072"
                                data-name="Rectangle 1072"
                                fill="none"
                                stroke="#f1f9ff"
                                stroke-width="2"
                            >
                                <rect
                                    width="30"
                                    height="30"
                                    rx="10"
                                    stroke="none"
                                />
                                <rect
                                    x="1"
                                    y="1"
                                    width="28"
                                    height="28"
                                    rx="9"
                                    fill="none"
                                />
                            </g>
                            <path
                                id="Path_36"
                                data-name="Path 36"
                                d="M4.7,6.1,0,1.4,1.4,0,4.7,3.3,8,0,9.4,1.4Z"
                                transform="translate(10 11.655)"
                                fill="#fff"
                            />
                        </svg>
                    </button>
                    <button
                        id="layoutTitleLeft"
                        class="zoomButton-left btn-lg no-select"
                    >
                        <svg
                            id="Group_306"
                            data-name="Group 306"
                            xmlns="http://www.w3.org/2000/svg"
                            width="30"
                            height="30"
                            viewBox="0 0 30 30"
                        >
                            <g
                                id="Rectangle_1072"
                                data-name="Rectangle 1072"
                                fill="none"
                                stroke="#f1f9ff"
                                stroke-width="2"
                            >
                                <rect
                                    width="30"
                                    height="30"
                                    rx="10"
                                    stroke="none"
                                />
                                <rect
                                    x="1"
                                    y="1"
                                    width="28"
                                    height="28"
                                    rx="9"
                                    fill="none"
                                />
                            </g>
                            <path
                                id="Path_36"
                                data-name="Path 36"
                                d="M4.7,6.1,0,1.4,1.4,0,4.7,3.3,8,0,9.4,1.4Z"
                                transform="translate(18.1 9.655) rotate(90)"
                                fill="#fff"
                            />
                        </svg>
                    </button>
                    <button
                        id="layoutTitleRight"
                        class="zoomButton-right btn-lg no-select"
                    >
                        <svg
                            id="Group_307"
                            data-name="Group 307"
                            xmlns="http://www.w3.org/2000/svg"
                            width="30"
                            height="30"
                            viewBox="0 0 30 30"
                        >
                            <g
                                id="Rectangle_1072"
                                data-name="Rectangle 1072"
                                fill="none"
                                stroke="#f1f9ff"
                                stroke-width="2"
                            >
                                <rect
                                    width="30"
                                    height="30"
                                    rx="10"
                                    stroke="none"
                                />
                                <rect
                                    x="1"
                                    y="1"
                                    width="28"
                                    height="28"
                                    rx="9"
                                    fill="none"
                                />
                            </g>
                            <path
                                id="Path_36"
                                data-name="Path 36"
                                d="M4.7,6.1,0,1.4,1.4,0,4.7,3.3,8,0,9.4,1.4Z"
                                transform="translate(12 19.055) rotate(-90)"
                                fill="#fff"
                            />
                        </svg>
                    </button>
                </div>
            </div>
            <div class="layout-title--enable">
                <span>Title Enabled:</span>
                <label class="switch">
                    <input id="toggleLayoutTitle" type="checkbox" checked />
                    <span class="slider"></span>
                </label>
            </div>
            <div class="">
                <button id="saveLayout" class="Layout-btn custom-btn--primary">
                    Save
                </button>

                <button
                    id="cancelLayout"
                    class="Layout-btn custom-btn--tertiary"
                >
                    Cancel
                </button>
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>
import { setupLayoutModePanelListeners } from '#/simulator/src/layoutMode'
import { onMounted } from '@vue/runtime-core'

onMounted(() => {
    setupLayoutModePanelListeners()
})
</script>
