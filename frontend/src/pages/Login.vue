<script setup>
import { ref } from "vue";
import { CdrButton, CdrInput, CdrBanner, CdrHeadingSans, CdrBody } from "@rei/cedar";

const email = ref("");
const password = ref("");
const loading = ref(false);
const error = ref("");

const login = async () => {
  loading.value = true;
  error.value = "";

  const res = await fetch("http://localhost:8000/auth/login", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email: email.value,
      password: password.value,
    }),
  });

  const data = await res.json();

  if (data.access_token) {
    localStorage.setItem("token", data.access_token);
    window.location.reload();
  } else {
    error.value = "Login failed. Check your credentials.";
  }

  loading.value = false;
};


</script>

<template>
  <div class="form-stack">
    <div>
      <CdrHeadingSans tag="h2" scale="1">Welcome back</CdrHeadingSans>
      <CdrBody class="muted">
        Log in to manage reimbursements.
      </CdrBody>
    </div>

    <CdrBanner v-if="error" type="error">{{ error }}</CdrBanner>

    <CdrInput v-model="email" label="Email" type="email" />
    <CdrInput v-model="password" label="Password" type="password" />

    <CdrButton :disabled="loading" @click="login">
      {{ loading ? "Logging in..." : "Login" }}
    </CdrButton>
  </div>
</template>
