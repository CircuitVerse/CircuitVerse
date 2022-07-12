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
    obj: { type: Object, default: undefined },
})
var helplink = props.obj && props.obj.helplink
function helpButtonClick() {
	window.open(helplink)
}
</script>