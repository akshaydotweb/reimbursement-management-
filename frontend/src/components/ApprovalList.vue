<script setup>
import { ref, onMounted } from "vue";
import {
  getPendingExpenses,
  approveExpense,
  rejectExpense,
} from "../api/api";

const expenses = ref([]);

const loading = ref(true);

const load = async () => {
  loading.value = true;
  expenses.value = await getPendingExpenses();
  loading.value = false;
};

const approve = async (id) => {
  await approveExpense(id, 2);
  load();
};

const reject = async (id) => {
  await rejectExpense(id, 2, "Invalid");
  load();
};

const getStatusStyle = (status) => {
  if (status === "PENDING") return "color: orange";
  if (status === "APPROVED") return "color: green";
  if (status === "REJECTED") return "color: red";
};

onMounted(load);
</script>

<template>
  <p v-if="loading">Loading...</p>
  <div>
    <h3>Pending Approvals</h3>

      <table border="1" cellpadding="8">
        <thead>
          <tr>
            <th>Amount</th>
            <th>Category</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="e in expenses" :key="e.id">
            <td>₹{{ e.amount }}</td>
            <td>{{ e.category }}</td>
            <td>
              <button @click="approve(e.id)">Approve</button>
              <button @click="reject(e.id)">Reject</button>
            </td>
          </tr>
        </tbody>
    </table>
  </div>
</template>