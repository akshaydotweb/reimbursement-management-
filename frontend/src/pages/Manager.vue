<script setup>
import { CdrHeadingSans, CdrBody } from "@rei/cedar";
import ApprovalList from "../components/ApprovalList.vue";
</script>

<template>
  <div class="section-stack">
    <div>
      <CdrHeadingSans tag="h2" scale="1">Manager Dashboard</CdrHeadingSans>
      <CdrBody class="muted">
        Review and act on pending approvals.
      </CdrBody>
    </div>
    <ApprovalList />
  </div>
</template>
