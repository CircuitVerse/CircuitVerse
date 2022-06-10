<template>
    <v-layout>
        <v-navigation-drawer
            color="grey-darken-2"
            permanent
        ></v-navigation-drawer>
        <v-app-bar color="grey-lighten-2">
            <h2>{{ $t("title") }}</h2>
        </v-app-bar>
        <v-main> <v-card height="200px"> </v-card> </v-main>
    </v-layout>
</template>

<script lang="ts" setup></script>
