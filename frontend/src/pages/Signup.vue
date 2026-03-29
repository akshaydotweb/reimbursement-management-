<script setup>
import { ref } from "vue";

const email = ref("");
const password = ref("");
const company = ref("");
const country = ref("");

const signup = async () => {
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

  console.log("SIGNUP RESPONSE:", data);

  if (data.msg) {
    alert("Signup successful! Now login.");
  } else {
    alert("Signup failed");
  }
};
</script>

<template>
  <div>
    <h2>Signup</h2>

    <input v-model="email" placeholder="Email" />
    <input v-model="password" type="password" placeholder="Password" />
    <input v-model="company" placeholder="Company Name" />
    <input v-model="country" placeholder="Country (e.g. India)" />

    <button @click="signup">Signup</button>
  </div>
</template>