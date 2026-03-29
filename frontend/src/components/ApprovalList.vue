<script setup>
import { ref, onMounted } from "vue";
import { CdrTable, CdrBanner, CdrButton, CdrHeadingSans, CdrBody } from "@rei/cedar";
import { getPendingApprovals, approveExpense, rejectExpense } from "../api/api";

const approvals = ref([]);
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
    const data = await getPendingApprovals();
    approvals.value = Array.isArray(data) ? data : [];
  } catch (err) {
    error.value = "Unable to load approvals.";
    approvals.value = [];
  } finally {
    loading.value = false;
  }
};

const approve = async (id) => {
  success.value = "";
  error.value = "";

  try {
    await approveExpense(id);
    success.value = "Expense approved.";
    load();
  } catch (err) {
    error.value = "Approval failed. Please try again.";
  }
};

const reject = async (id) => {
  success.value = "";
  error.value = "";

  try {
    await rejectExpense(id);
    success.value = "Expense rejected.";
    load();
  } catch (err) {
    error.value = "Rejection failed. Please try again.";
  }
};

onMounted(load);
</script>
<template>
  <div class="surface-card section-stack">
    <div>
      <CdrHeadingSans tag="h3" scale="1">Approvals to review</CdrHeadingSans>
      <CdrBody class="muted">
        Only pending approvals assigned to you are shown.
      </CdrBody>
    </div>

    <CdrBanner v-if="error" type="error">{{ error }}</CdrBanner>
    <CdrBanner v-if="success" type="success">{{ success }}</CdrBanner>
    <CdrBody v-if="loading">Loading approvals...</CdrBody>
    <CdrBody v-else-if="approvals.length === 0">No pending approvals.</CdrBody>

    <div v-else class="table-wrap">
      <CdrTable>
        <thead>
          <tr>
            <th>Employee</th>
            <th>Category</th>
            <th>Amount</th>
            <th>Status</th>
            <th class="align-right">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in approvals" :key="item.approval.id">
            <td>{{ item.employee?.email || `Employee ${item.expense.user_id}` }}</td>
            <td>{{ item.expense.category }}</td>
            <td>{{ item.expense.currency }} {{ item.expense.amount }}</td>
            <td>{{ mapStatus(item.expense.status) }}</td>
            <td class="align-right">
              <div class="cta-row" style="justify-content: flex-end;">
                <CdrButton size="small" @click="approve(item.expense.id)">
                  Approve
                </CdrButton>
                <CdrButton size="small" variant="secondary" @click="reject(item.expense.id)">
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
