<script setup>
import { ref } from "vue";
import Employee from "./pages/Employee.vue";
import Manager from "./pages/Manager.vue";
import Admin from "./pages/Admin.vue";

const page = ref("employee");
</script>

<template>
  <div>
    <button @click="page='employee'">Employee</button>
    <button @click="page='manager'">Manager</button>
    <button @click="page='admin'">Admin</button>

    <Employee v-if="page==='employee'" />
    <Manager v-if="page==='manager'" />
    <Admin v-if="page==='admin'" />
  </div>
</template>
