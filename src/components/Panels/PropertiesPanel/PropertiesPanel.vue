<template>
    <ModuleProperty
        v-if="!propertiesPanelStore.inLayoutMode"
        :panle-body-data="toRaw(propertiesPanelStore.propertiesPanelObj)"
        :panel-type="propertiesPanelStore.panelType"
        :panel-body-header="propertiesPanelStore.panelBodyHeader"
    />
    <LayoutProperty v-else />
</template>

<script lang="ts" setup>
import ModuleProperty from '#/components/Panels/PropertiesPanel/ModuleProperty/ModuleProperty.vue'
import LayoutProperty from '#/components/Panels/PropertiesPanel/LayoutProperty/LayoutProperty.vue'
import { toRaw, onMounted } from 'vue'
import { showPropertiesPanel } from './PropertiesPanel';
import { usePropertiesPanelStore } from '#/store/propertiesPanelStore';

const propertiesPanelStore = usePropertiesPanelStore();

onMounted(() => {
    // checks for which type of properties panel to show
    setInterval(showPropertiesPanel, 100)
})
</script>
