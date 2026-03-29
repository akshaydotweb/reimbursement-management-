<script setup>
import { ref, onMounted } from "vue";
import { CdrTable, CdrBanner, CdrHeadingSans, CdrBody } from "@rei/cedar";
import { getExpenses } from "../api/api";

const expenses = ref([]);
const loading = ref(false);
const error = ref("");

const mapStatus = (status) => {
  if (status === "SUBMITTED") return "Pending";
  if (status === "PENDING") return "Pending";
  if (status === "APPROVED") return "Approved";
  if (status === "REJECTED") return "Rejected";
  return status || "Unknown";
};

const loadExpenses = async () => {
  loading.value = true;
  error.value = "";

  try {
    const data = await getExpenses();
    expenses.value = Array.isArray(data) ? data : [];
  } catch (err) {
    error.value = "Unable to load team expenses.";
    expenses.value = [];
  } finally {
    loading.value = false;
  }
};

onMounted(loadExpenses);
</script>

<template>
  <div class="surface-card section-stack">
    <div>
      <CdrHeadingSans tag="h3" scale="1">Team expenses</CdrHeadingSans>
      <CdrBody class="muted">
        Visibility for your direct reports.
      </CdrBody>
    </div>

    <CdrBanner v-if="error" type="error">{{ error }}</CdrBanner>
    <CdrBody v-if="loading">Loading team expenses...</CdrBody>
    <CdrBody v-else-if="expenses.length === 0">No team expenses yet.</CdrBody>

    <div v-else class="table-wrap">
      <CdrTable>
        <thead>
          <tr>
            <th>Employee</th>
            <th>Category</th>
            <th>Amount</th>
            <th>Date</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="e in expenses" :key="e.id">
            <td>{{ e.user_id }}</td>
            <td>{{ e.category }}</td>
            <td>
              {{ e.display_currency || e.currency }}
              {{ e.display_amount ?? e.amount }}
            </td>
            <td>{{ e.expense_date || "—" }}</td>
            <td>{{ mapStatus(e.status) }}</td>
          </tr>
        </tbody>
      </CdrTable>
    </div>
  </div>
</template>
