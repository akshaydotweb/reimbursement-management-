<script setup>
import { ref } from "vue";
import { CdrHeadingSans, CdrBody } from "@rei/cedar";
import ExpenseForm from "../components/ExpenseForm.vue";
import ExpenseList from "../components/ExpenseList.vue";

const refreshKey = ref(0);

const refreshList = () => {
  refreshKey.value++;
};
</script>

<template>
  <div class="section-stack">
    <div>
      <CdrHeadingSans tag="h2" scale="1">Employee Dashboard</CdrHeadingSans>
      <CdrBody class="muted">
        Submit expenses and monitor approvals.
      </CdrBody>
    </div>
    <div class="page-grid two-col">
      <ExpenseForm @refresh="refreshList" />
      <ExpenseList :key="refreshKey" />
    </div>
  </div>
</template>
