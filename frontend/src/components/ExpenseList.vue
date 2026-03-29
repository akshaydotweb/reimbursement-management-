<script setup>
import { ref, onMounted } from "vue";
import { getAllExpenses } from "../api/api";

const expenses = ref([]);

const loadExpenses = async () => {
  const data = await getAllExpenses();
  expenses.value = data;
};

const getStatusStyle = (status) => {
  if (status === "SUBMITTED") return "color: orange";
  if (status === "APPROVED") return "color: green";
  return "color: gray";
};

onMounted(loadExpenses);
</script>

<template>
  <div>
    <h3>My Expenses</h3>

    <table border="1" cellpadding="8">
      <thead>
        <tr>
          <th>Amount</th>
          <th>Category</th>
          <th>Status</th>
        </tr>
      </thead>

      <tbody>
        <tr v-for="e in expenses" :key="e.id">
          <td>₹{{ e.amount }}</td>
          <td>{{ e.category }}</td>
          <td>
            <span :style="getStatusStyle(e.status)">
              {{ e.status }}
            </span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>