<template>
    <ul class="dropdown-menu" >
        <li 
            :key="listItem.id" 
            v-for="listItem in listItems"
        >   
            <a 
                class="dropdown-item" 
                :class="dropDownType ==  'navLink' ? 'logixButton text-left pl-1':''" 
                :id="listItem.itemid" 
                style="white-space: pre-line;"
            >{{listItem.item}}
            </a>
        </li>
        <div class="dropdown-divider" v-if="dropDownType=='user'"></div>
        <li v-if="dropDownType=='user'">
            <a class="dropdown-item" rel="nofollow" data-method="delete">Sign Out</a>
        </li>
    </ul>
</template>

<script>
export default {
    name: 'DropDown',
    props: {
        listItems: Array,
        dropDownType : {
            type: String,
            default: ""
        },
    },
}
</script>