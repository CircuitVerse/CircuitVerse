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
                >{{ listItem.item }}
            </a>
        </li>
        <div v-if="dropDownType == 'user'" class="dropdown-divider"></div>
        <li v-if="dropDownType == 'user'">
            <a class="dropdown-item" rel="nofollow" data-method="delete"
                >Sign Out</a
            >
        </li>
    </ul>
</template>

<script>
export default {
    name: 'DropDown',
    props: {
        listItems: Array,
        dropDownType: {
            type: String,
            default: '',
        },
    },
}
</script>
