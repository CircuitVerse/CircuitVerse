<template>
    <div
        ondrag="(() => {$('.quick-btn').css({'box-shadow': 'none', 'background': 'var(--bg-navbar)'})})()"
        class="quick-btn"
    >
        <div id="dragQPanel" class="panel-drag">
            <span>
                <svg
                    style="height: 20px"
                    xmlns="http://www.w3.org/2000/svg"
                    xmlns:xlink="http://www.w3.org/1999/xlink"
                    width="18"
                    height="31"
                    viewBox="0 0 18 31"
                >
                    <defs>
                        <clipPath id="clip-path">
                            <rect width="18" height="31" fill="none" />
                        </clipPath>
                    </defs>
                    <g
                        id="Repeat_Grid_1"
                        data-name="Repeat Grid 1"
                        clip-path="url(#clip-path)"
                    >
                        <g transform="translate(-21 -29)">
                            <circle
                                id="Ellipse_1"
                                data-name="Ellipse 1"
                                cx="2"
                                cy="2"
                                r="2"
                                transform="translate(22 30)"
                                fill="#fff"
                            />
                        </g>
                        <g transform="translate(-12 -29)">
                            <circle
                                id="Ellipse_1-2"
                                data-name="Ellipse 1"
                                cx="2"
                                cy="2"
                                r="2"
                                transform="translate(22 30)"
                                fill="#fff"
                            />
                        </g>
                        <g transform="translate(-21 -18)">
                            <circle
                                id="Ellipse_1-3"
                                data-name="Ellipse 1"
                                cx="2"
                                cy="2"
                                r="2"
                                transform="translate(22 30)"
                                fill="#fff"
                            />
                        </g>
                        <g transform="translate(-12 -18)">
                            <circle
                                id="Ellipse_1-4"
                                data-name="Ellipse 1"
                                cx="2"
                                cy="2"
                                r="2"
                                transform="translate(22 30)"
                                fill="#fff"
                            />
                        </g>
                        <g transform="translate(-21 -7)">
                            <circle
                                id="Ellipse_1-5"
                                data-name="Ellipse 1"
                                cx="2"
                                cy="2"
                                r="2"
                                transform="translate(22 30)"
                                fill="#fff"
                            />
                        </g>
                        <g transform="translate(-12 -7)">
                            <circle
                                id="Ellipse_1-6"
                                data-name="Ellipse 1"
                                cx="2"
                                cy="2"
                                r="2"
                                transform="translate(22 30)"
                                fill="#fff"
                            />
                        </g>
                    </g>
                </svg>
            </span>
        </div>
        <div>
            <button
                id="save"
                type="button"
                class="quick-btn-save-online logixButton"
                title="Save Online"
                onclick=""
            ></button>
        </div>
        <div>
            <button
                id="saveOffline"
                type="button"
                class="quick-btn-save logixButton"
                title="Save Offline"
                onclick=""
            ></button>
        </div>
        <div>
            <button
                id="deleteSelected"
                type="button"
                class="quick-btn-delete"
                title="Delete Selected"
            ></button>
        </div>
        <div>
            <button
                id="createSaveAsImgPrompt"
                type="button"
                class="quick-btn-download logixButton"
                title="Download as Image"
                onclick=""
            ></button>
        </div>
        <div>
            <button
                type="button"
                class="quick-btn-zoom-fit"
                title="Fit to Screen"
                onclick="globalScope.centerFocus(false)"
            ></button>
        </div>
        <div>
            <button
                id="undoButton"
                type="button"
                class="quick-btn-undo"
                title="Undo"
            ></button>
        </div>
        <div>
            <button
                id="redoButton"
                type="button"
                class="quick-btn-redo"
                title="Redo"
            ></button>
        </div>
        <div>
            <button
                id="viewButton"
                type="button"
                class="quick-btn-view"
                title="Preview Circuit"
            >
                <i style="color: #ddd" class="fas fa-expand-arrows-alt"></i>
            </button>
        </div>
        <div class="zoom-slider">
            <button id="decrement" class="zoom-slider-decrement">-</button>
            <input
                id="customRange1"
                type="range"
                class="custom-range"
                min="0"
                max="45"
                step="1"
            />
            <span id="slider_value"></span>
            <button id="increment" class="zoom-slider-increment">+</button>
        </div>
    </div>
</template>

<script lang="ts" setup></script>

<style scoped>
/* @import url('./QuickButton.css'); */
</style>
