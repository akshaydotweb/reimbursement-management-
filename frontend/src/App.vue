<script setup>
import { ref } from "vue";
import Login from "./pages/Login.vue";
import Signup from "./pages/Signup.vue";
import Employee from "./pages/Employee.vue";
import Manager from "./pages/Manager.vue";

const page = ref("login");
const token = localStorage.getItem("token");
</script>

<template>
  <div>
    <h1>Reimbursement System</h1>

    <!-- NOT LOGGED IN -->
    <div v-if="!token">
      <button @click="page='login'">Login</button>
      <button @click="page='signup'">Signup</button>

      <Login v-if="page==='login'" />
      <Signup v-if="page==='signup'" />
    </div>

    <!-- LOGGED IN -->
    <div v-else>
      <button @click="page='employee'">Employee</button>
      <button @click="page='manager'">Manager</button>

      <Employee v-if="page==='employee'" />
      <Manager v-if="page==='manager'" />
    </div>
  </div>
</template>