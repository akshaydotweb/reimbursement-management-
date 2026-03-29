<script setup>
import { ref, onMounted } from "vue";
import { CdrButton, CdrInput, CdrBanner, CdrHeadingSans, CdrBody, CdrSelect } from "@rei/cedar";

const email = ref("");
const password = ref("");
const company = ref("");
const country = ref("");
const loading = ref(false);
const success = ref("");
const error = ref("");
const countries = ref([]);
const loadingCountries = ref(false);
const countryError = ref("");

const loadCountries = async () => {
  loadingCountries.value = true;
  countryError.value = "";
  try {
    const res = await fetch(
      "https://restcountries.com/v3.1/all?fields=name,currencies"
    );
    const data = await res.json();
    countries.value = Array.isArray(data)
      ? data
          .map((c) => c?.name?.common)
          .filter(Boolean)
          .sort((a, b) => a.localeCompare(b))
      : [];
  } catch (err) {
    countryError.value = "Unable to load countries.";
  } finally {
    loadingCountries.value = false;
  }
};

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

onMounted(loadCountries);
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
    <div class="form-stack">
      <CdrBody class="muted">Country</CdrBody>
      <CdrBanner v-if="countryError" type="error">{{ countryError }}</CdrBanner>
      <CdrBody v-if="loadingCountries">Loading countries...</CdrBody>
      <CdrInput v-else-if="countries.length === 0" v-model="country" label="Country" />
      <CdrSelect
        v-else
        v-model="country"
        label="Country"
        prompt="Select a country"
      >
        <option v-for="c in countries" :key="c" :value="c">{{ c }}</option>
      </CdrSelect>
    </div>
    <CdrInput v-model="email" label="Admin email" type="email" />
    <CdrInput v-model="password" label="Password" type="password" />

    <CdrButton :disabled="loading" @click="signup">
      {{ loading ? "Creating..." : "Create account" }}
    </CdrButton>
  </div>
</template>
