<template>
    <ul class="dropdown-menu">
        <li v-for="listItem in listItems" :key="listItem.id">
            <a
                :id="listItem.itemid"
                class="dropdown-item"
                :class="
                    dropDownType == 'navLink'
                        ? 'logixButton text-left pl-1'
                        : ''
                "
                style="white-space: pre-line"
            >
                {{
                    $t('simulator.nav.' + dropDownHeader + '.' + listItem.item)
                }}
            </a>
        </li>
        <div v-if="dropDownType == 'user'" class="dropdown-divider"></div>
        <li v-if="dropDownType == 'user'">
            <a class="dropdown-item" rel="nofollow" data-method="delete">
                {{ $t('simulator.nav.sign_out') }}
            </a>
        </li>
    </ul>
</template>

<script lang="ts" setup>
const props = defineProps({
    listItems: { type: Array, default: () => [] },
    dropDownHeader: { type: String, default: '' },
    dropDownType: { type: String, default: '' },
})
console.log(props.dropDownHeader)
console.log(props.listItems)
</script>
