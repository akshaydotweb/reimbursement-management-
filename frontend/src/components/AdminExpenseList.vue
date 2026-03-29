<script setup>
import { ref, onMounted } from "vue";
import { CdrTable, CdrBanner, CdrHeadingSans, CdrBody, CdrButton } from "@rei/cedar";
import { getAllExpenses, overrideExpense } from "../api/api";

const expenses = ref([]);
const loading = ref(false);
const error = ref("");
const success = ref("");

const mapStatus = (status) => {
  if (status === "SUBMITTED") return "Pending";
  if (status === "PENDING") return "Pending";
  if (status === "APPROVED") return "Approved";
  if (status === "REJECTED") return "Rejected";
  return status || "Unknown";
};

const load = async () => {
  loading.value = true;
  error.value = "";
  success.value = "";

  try {
    const data = await getAllExpenses();
    expenses.value = Array.isArray(data) ? data : [];
  } catch (err) {
    error.value = "Unable to load expenses.";
  } finally {
    loading.value = false;
  }
};

const overrideStatus = async (id, status) => {
  error.value = "";
  success.value = "";
  try {
    await overrideExpense(id, status);
    success.value = `Expense ${status.toLowerCase()}.`;
    load();
  } catch (err) {
    error.value = "Override failed.";
  }
};

onMounted(load);
</script>

<template>
  <div class="surface-card section-stack">
    <div>
      <CdrHeadingSans tag="h3" scale="1">All expenses</CdrHeadingSans>
      <CdrBody class="muted">
        Admin override available for audit or correction.
      </CdrBody>
    </div>

    <CdrBanner v-if="success" type="success">{{ success }}</CdrBanner>
    <CdrBanner v-if="error" type="error">{{ error }}</CdrBanner>
    <CdrBody v-if="loading">Loading expenses...</CdrBody>
    <CdrBody v-else-if="expenses.length === 0">No expenses yet.</CdrBody>

    <div v-else class="table-wrap">
      <CdrTable>
        <thead>
          <tr>
            <th>User</th>
            <th>Category</th>
            <th>Amount</th>
            <th>Status</th>
            <th class="align-right">Override</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="e in expenses" :key="e.id">
            <td>{{ e.user_id }}</td>
            <td>{{ e.category }}</td>
            <td>{{ e.currency }} {{ e.amount }}</td>
            <td>{{ mapStatus(e.status) }}</td>
            <td class="align-right">
              <div class="cta-row" style="justify-content: flex-end;">
                <CdrButton size="small" @click="overrideStatus(e.id, 'APPROVED')">
                  Approve
                </CdrButton>
                <CdrButton size="small" modifier="secondary" @click="overrideStatus(e.id, 'REJECTED')">
                  Reject
                </CdrButton>
              </div>
            </td>
          </tr>
        </tbody>
      </CdrTable>
    </div>
  </div>
</template>
