<script setup>
import { ref, onMounted } from "vue";
import { getPendingExpenses, approveExpense, rejectExpense } from "../api/api";

const expenses = ref([]);

const load = async () => {
  expenses.value = await getPendingExpenses();
};

const approve = async (id) => {
  await approveExpense(id, 2);
  load();
};

const reject = async (id) => {
  await rejectExpense(id, 2, "Invalid");
  load();
};

onMounted(load);
</script>

<template>
  <div>
    <h3>Pending Approvals</h3>
    <ul>
      <li v-for="e in expenses" :key="e.id">
        ₹{{ e.amount }} - {{ e.category }}
        <button @click="approve(e.id)">Approve</button>
        <button @click="reject(e.id)">Reject</button>
      </li>
    </ul>
  </div>
</template>
