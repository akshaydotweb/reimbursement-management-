<script setup>
import { ref } from "vue";
import { createExpense } from "../api/api";

const amount = ref("");
const category = ref("");
const description = ref("");

const submitExpense = async () => {
  const data = {
    user_id: 1,
    amount: Number(amount.value),
    category: category.value,
    description: description.value,
  };

  const res = await createExpense(data);
  console.log("Created:", res);

  amount.value = "";
  category.value = "";
  description.value = "";
};
</script>

<template>
  <div>
    <h3>Submit Expense</h3>
    <input v-model="amount" placeholder="Amount" />
    <input v-model="category" placeholder="Category" />
    <input v-model="description" placeholder="Description" />
    <button @click="submitExpense">Submit</button>
  </div>
</template>
