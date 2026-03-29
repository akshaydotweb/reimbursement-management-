<script setup>
import { ref } from "vue";
import Employee from "./pages/Employee.vue";
import Manager from "./pages/Manager.vue";

const page = ref("employee");
</script>

<template>
  <div>
    <h1>Reimbursement System</h1>

    <button @click="page='employee'">Employee</button>
    <button @click="page='manager'">Manager</button>

    <Employee v-if="page==='employee'" />
    <Manager v-if="page==='manager'" />
  </div>
</template>