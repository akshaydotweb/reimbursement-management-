<script setup>
import { CdrHeadingSans, CdrBody } from "@rei/cedar";
import UserForm from "../components/UserForm.vue";
import AdminApprovalRules from "../components/AdminApprovalRules.vue";
import AdminExpenseList from "../components/AdminExpenseList.vue";
</script>

<template>
  <div class="section-stack">
    <div>
      <CdrHeadingSans tag="h2" scale="1">Admin Panel</CdrHeadingSans>
      <CdrBody class="muted">
        Manage users, roles, and reporting lines.
      </CdrBody>
    </div>
    <div class="page-grid two-col">
      <UserForm />
      <AdminApprovalRules />
    </div>
    <AdminExpenseList />
  </div>
</template>
