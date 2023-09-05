<template>
    <div class="report-sidebar">
        <a
            type="button"
            class="btn btn-primary text-light"
            data-toggle="modal"
            data-target=".issue"
            @click="openReportingModal"
        >
            <span class="fa fa-bug"></span>&nbsp;&nbsp;{{
                $t('simulator.report_issue')
            }}</a
        >
    </div>
</template>

<script lang="ts" setup>
import { defineEmits } from 'vue'

const emit = defineEmits(['openReportModal'])

function openReportingModal() {
    emit('openReportModal', openReportingModal)
}
</script>
