<script setup>
import { ref } from "vue";
import { CdrButton, CdrInput, CdrBanner, CdrHeadingSans, CdrBody } from "@rei/cedar";

const email = ref("");
const password = ref("");
const company = ref("");
const country = ref("");
const loading = ref(false);
const success = ref("");
const error = ref("");

const signup = async () => {
  loading.value = true;
  success.value = "";
  error.value = "";

  const res = await fetch("http://localhost:8000/auth/signup", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email: email.value,
      password: password.value,
      company_name: company.value,
      country: country.value,
    }),
  });

  const data = await res.json();

  if (data.msg) {
    success.value = "Signup successful! Please log in.";
  } else {
    error.value = "Signup failed. Please check your details.";
  }

  loading.value = false;
};
</script>

<template>
  <div class="form-stack">
    <div>
      <CdrHeadingSans tag="h2" scale="1">Create your company</CdrHeadingSans>
      <CdrBody class="muted">
        Set up your organization and admin account.
      </CdrBody>
    </div>

    <CdrBanner v-if="success" type="success">{{ success }}</CdrBanner>
    <CdrBanner v-if="error" type="error">{{ error }}</CdrBanner>

    <CdrInput v-model="company" label="Company name" />
    <CdrInput v-model="country" label="Country" helperTextBottom="Example: India" />
    <CdrInput v-model="email" label="Admin email" type="email" />
    <CdrInput v-model="password" label="Password" type="password" />

    <CdrButton :disabled="loading" @click="signup">
      {{ loading ? "Creating..." : "Create account" }}
    </CdrButton>
  </div>
</template>
