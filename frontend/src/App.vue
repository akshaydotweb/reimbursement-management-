<script setup>
import { ref } from "vue";
import Employee from "./pages/Employee.vue";
import Manager from "./pages/Manager.vue";

const page = ref("employee");
</script>

<template>
  <div style="padding: 20px; font-family: sans-serif;">
    <h1>Reimbursement System</h1>

    <div style="margin-bottom: 20px;">
      <button @click="page='employee'">Employee</button>
      <button @click="page='manager'">Manager</button>
    </div>

    <div style="border: 1px solid #ccc; padding: 20px;">
      <Employee v-if="page==='employee'" />
      <Manager v-if="page==='manager'" />
    </div>
  </div>
</template>