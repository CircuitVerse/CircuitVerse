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
                v-bind="
                    Object.fromEntries(
                        listItem.attributes.map((attr) => [
                            attr.name,
                            attr.value.replace('${:id}', userId),
                        ])
                    )
                "
            >
                {{
                    $t('simulator.nav.' + dropDownHeader + '.' + listItem.item)
                }}
            </a>
        </li>
        <div v-if="dropDownType == 'user'" class="dropdown-divider"></div>
        <li v-if="dropDownType == 'user'">
            <a
                href="/users/sign_out"
                class="dropdown-item"
                rel="nofollow"
                data-method="delete"
            >
                {{ $t('simulator.nav.sign_out') }}
            </a>
        </li>
    </ul>
</template>

<script lang="ts" setup>
import { useAuthStore } from '#/store/authStore'

const props = defineProps({
    listItems: { type: Array<{
        id: string
        item: string
        itemid: string
        attributes: Array<{
            name: string
            value: string
        }>
    }>, default: () => [] },
    dropDownHeader: { type: String, default: '' },
    dropDownType: { type: String, default: '' },
})
const userId = useAuthStore().getUserId
</script>
