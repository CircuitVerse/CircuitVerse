<template>
	<p v-if="helplink" class="btn-parent">
		<button 
			id="HelpButton" 
			class="btn btn-primary btn-xs" type="button" 
			@click="helpButtonClick"
		>
			&#9432 Help
		</button>
	</p>
</template>

<script lang="ts" setup>
const props = defineProps({
    data: { type: Object, default: undefined },
})
const obj = props.data
var helplink = obj && obj.helplink
function helpButtonClick() {
	window.open(helplink)
}
</script>