<script setup>
import { ref, computed, onMounted } from "vue";
import {
  CdrButton,
  CdrContainer,
  CdrSurface,
  CdrBanner,
  CdrLayout,
  CdrHeadingSans,
  CdrBody,
} from "@rei/cedar";
import Login from "./pages/Login.vue";
import Signup from "./pages/Signup.vue";
import Employee from "./pages/Employee.vue";
import Manager from "./pages/Manager.vue";
import Admin from "./pages/Admin.vue";
import { getCurrentUser } from "./api/api";

const page = ref("login");
const token = ref(localStorage.getItem("token"));

const decodeJwt = (raw) => {
  if (!raw) return null;
  const parts = raw.split(".");
  if (parts.length !== 3) return null;

  try {
    const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, "=");
    const json = atob(padded);
    return JSON.parse(json);
  } catch {
    return null;
  }
};

const currentUser = ref(decodeJwt(token.value));
const role = computed(() => (currentUser.value?.role || "").toUpperCase());
const roleLabel = computed(() => role.value || "");
const loadingUser = ref(false);
const userError = ref("");

const logout = () => {
  localStorage.removeItem("token");
  window.location.reload();
};

const loadCurrentUser = async () => {
  if (!token.value) return;
  if (currentUser.value?.role && currentUser.value?.email) return;

  loadingUser.value = true;
  userError.value = "";

  try {
    const data = await getCurrentUser();
    currentUser.value = data;
  } catch (err) {
    userError.value = "Session expired. Please log in again.";
  } finally {
    loadingUser.value = false;
  }
};

onMounted(loadCurrentUser);
</script>

<template>
  <CdrContainer class="app-shell">
    <div class="app-header">
      <div class="app-title">
        <CdrHeadingSans tag="h1" scale="2">Reimbursement Hub</CdrHeadingSans>
        <CdrBody class="muted">
          Submit, track, and approve expenses with clarity.
        </CdrBody>
      </div>
      <div v-if="currentUser" class="cta-row">
        <span class="pill">
          {{ currentUser.email || currentUser.username || currentUser.sub }}
          <span v-if="roleLabel">&nbsp;·&nbsp;{{ roleLabel }}</span>
        </span>
        <CdrButton variant="secondary" @click="logout">Logout</CdrButton>
      </div>
    </div>

    <CdrBanner v-if="userError" type="error">{{ userError }}</CdrBanner>

    <!-- NOT LOGGED IN -->
    <div v-if="!currentUser && !loadingUser" class="section-stack">
      <div class="cta-row">
        <CdrButton :style="{ minWidth: '140px' }" @click="page='login'">
          Login
        </CdrButton>
        <CdrButton variant="secondary" @click="page='signup'">
          Signup
        </CdrButton>
      </div>

      <CdrSurface class="surface-card">
        <Login v-if="page==='login'" />
        <Signup v-if="page==='signup'" />
      </CdrSurface>
    </div>

    <div v-else-if="loadingUser" class="surface-card">
      <CdrBody>Loading your workspace...</CdrBody>
    </div>

    <!-- LOGGED IN -->
    <CdrLayout v-else class="page-grid">
      <CdrSurface class="surface-card">
        <Admin v-if="role==='ADMIN'" />
        <Employee v-else-if="role==='EMPLOYEE'" />
        <Manager v-else-if="role==='MANAGER'" />
        <CdrBody v-else>
          Unsupported role.
        </CdrBody>
      </CdrSurface>
    </CdrLayout>
  </CdrContainer>
</template>
