<script setup>
import { CdrHeadingSans, CdrBody } from "@rei/cedar";
import UserForm from "../components/UserForm.vue";
</script>

<template>
  <div class="section-stack">
    <div>
      <CdrHeadingSans tag="h2" scale="1">Admin Panel</CdrHeadingSans>
      <CdrBody class="muted">
        Manage users, roles, and reporting lines.
      </CdrBody>
    </div>
    <UserForm />
  </div>
</template>
