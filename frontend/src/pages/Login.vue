<script setup>
import { ref } from "vue";

const email = ref("");
const password = ref("");

const login = async () => {
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

  console.log("LOGIN RESPONSE:", data); // 👈 ADD THIS

  if (data.access_token) {
    localStorage.setItem("token", data.access_token);
    alert("Login successful");
    window.location.reload();
  } else {
    alert("Login failed");
  }
};


</script>

<template>
  <div>
    <h2>Login</h2>

    <input v-model="email" placeholder="Email" />
    <input v-model="password" type="password" placeholder="Password" />

    <button @click="login">Login</button>
  </div>
</template>