<script setup>
import { ref, onMounted } from "vue";
import {
  CdrButton,
  CdrInput,
  CdrSelect,
  CdrBanner,
  CdrHeadingSans,
  CdrBody,
} from "@rei/cedar";
import { createUser } from "../api/api";

const email = ref("");
const password = ref("");
const role = ref("EMPLOYEE");
const managerId = ref("");
const managers = ref([]);
const managersLoading = ref(false);
const managersError = ref("");
const success = ref("");
const error = ref("");
const submitting = ref(false);

const BASE_URL = "http://localhost:8000";

const loadManagers = async () => {
  managersLoading.value = true;
  managersError.value = "";

  try {
  const res = await fetch(`${BASE_URL}/users`, {
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${localStorage.getItem("token")}`,
    },
    });

    const data = await res.json();
    if (!Array.isArray(data)) {
      managers.value = [];
      return;
    }

    managers.value = data.filter((u) => u.role === "MANAGER");
  } catch (err) {
    managersError.value = "Unable to load managers.";
    managers.value = [];
  } finally {
    managersLoading.value = false;
  }
};

const submit = async () => {
  success.value = "";
  error.value = "";
  submitting.value = true;

  const data = {
    email: email.value,
    password: password.value,
    role: role.value,
    manager_id:
      role.value === "EMPLOYEE" && managerId.value
        ? Number(managerId.value)
        : null,
  };

  try {
    const res = await createUser(data);
    if (res?.msg) {
      success.value = res.msg;
    } else {
      success.value = "User created.";
    }

    email.value = "";
    password.value = "";
    managerId.value = "";
  } catch (err) {
    error.value = "Failed to create user.";
  } finally {
    submitting.value = false;
  }
};

onMounted(loadManagers);
</script>

<template>
  <div class="surface-card form-stack">
    <div>
      <CdrHeadingSans tag="h3" scale="1">Create User</CdrHeadingSans>
      <CdrBody class="muted">
        Add employees or managers and assign reporting.
      </CdrBody>
    </div>

    <CdrBanner v-if="success" type="success">{{ success }}</CdrBanner>
    <CdrBanner v-if="error" type="error">{{ error }}</CdrBanner>

    <CdrInput v-model="email" label="Email" type="email" />
    <CdrInput v-model="password" label="Temporary password" type="password" />

    <CdrSelect v-model="role" label="Role">
      <option value="EMPLOYEE">Employee</option>
      <option value="MANAGER">Manager</option>
    </CdrSelect>

    <!-- Only for employee -->
    <div v-if="role === 'EMPLOYEE'" class="form-stack">
      <CdrBanner v-if="managersError" type="error">{{ managersError }}</CdrBanner>
      <CdrBody v-if="managersLoading">Loading managers...</CdrBody>
      <CdrSelect v-else v-model="managerId" label="Manager">
        <option disabled value="">Select Manager</option>
        <option v-for="m in managers" :key="m.id" :value="m.id">
          {{ m.email }}
        </option>
      </CdrSelect>
      <CdrBody v-if="!managersLoading && managers.length === 0">
        No managers available.
      </CdrBody>
    </div>

    <CdrButton
      @click="submit"
      :disabled="submitting || (role === 'EMPLOYEE' && !managerId)"
    >
      {{ submitting ? "Creating..." : "Create user" }}
    </CdrButton>
  </div>
</template>
