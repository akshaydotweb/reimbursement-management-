<script setup>
import { CdrHeadingSans, CdrBody } from "@rei/cedar";
import ApprovalList from "../components/ApprovalList.vue";
import TeamExpenseList from "../components/TeamExpenseList.vue";
</script>

<template>
  <div class="section-stack">
    <div>
      <CdrHeadingSans tag="h2" scale="1">Manager Dashboard</CdrHeadingSans>
      <CdrBody class="muted">
        Review and act on pending approvals.
      </CdrBody>
    </div>
    <div class="page-grid two-col">
      <ApprovalList />
      <TeamExpenseList />
    </div>
  </div>
</template>
