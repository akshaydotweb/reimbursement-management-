<script setup>
import { onMounted, ref } from "vue";
import { getExpenses } from "../api/api";

const expenses = ref([]);

const loadExpenses = async () => {
  expenses.value = await getExpenses(1);
};

onMounted(loadExpenses);
</script>

<template>
  <div>
    <h3>My Expenses</h3>
    <ul>
      <li v-for="e in expenses" :key="e.id">
        ₹{{ e.amount }} - {{ e.category }} - {{ e.status }}
      </li>
    </ul>
  </div>
</template>
