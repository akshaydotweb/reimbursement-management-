<script setup>
import { ref } from "vue";
import {
  CdrButton,
  CdrInput,
  CdrSelect,
  CdrBanner,
  CdrHeadingSans,
  CdrBody,
} from "@rei/cedar";
const emit = defineEmits(["refresh"]);
import { createExpense } from "../api/api";

const amount = ref("");
const currency = ref("INR");
const category = ref("");
const description = ref("");
const loading = ref(false);
const success = ref("");
const error = ref("");

const submitExpense = async () => {
  loading.value = true;
  success.value = "";
  error.value = "";

  try {
    const data = {
      amount: Number(amount.value),
      currency: currency.value,
      description: description.value,
      category: category.value,
    };

    await createExpense(data);

    success.value = "Expense submitted.";
    amount.value = "";
    category.value = "";
    description.value = "";
    currency.value = "INR";
    emit("refresh");
  } catch (err) {
    error.value = "Failed to submit expense.";
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="surface-card form-stack">
    <div>
      <CdrHeadingSans tag="h3" scale="1">Submit Expense</CdrHeadingSans>
      <CdrBody class="muted">
        Add expense details and submit for approval.
      </CdrBody>
    </div>

    <CdrBanner v-if="success" type="success">{{ success }}</CdrBanner>
    <CdrBanner v-if="error" type="error">{{ error }}</CdrBanner>

    <CdrInput v-model="amount" label="Amount" type="number" />
    <CdrSelect v-model="currency" label="Currency">
      <option value="INR">INR</option>
      <option value="USD">USD</option>
      <option value="EUR">EUR</option>
    </CdrSelect>
    <CdrInput v-model="category" label="Category" />
    <CdrInput v-model="description" label="Description" />

    <CdrButton :disabled="loading" @click="submitExpense">
      {{ loading ? "Submitting..." : "Submit" }}
    </CdrButton>
  </div>
</template>
