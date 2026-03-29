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
const expenseDate = ref("");
const paidBy = ref("");
const remarks = ref("");
const receiptUrl = ref("");
const ocrText = ref("");
const loading = ref(false);
const success = ref("");
const error = ref("");
const uploading = ref(false);

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
      expense_date: expenseDate.value || null,
      paid_by: paidBy.value || null,
      remarks: remarks.value || null,
      receipt_url: receiptUrl.value || null,
    };

    await createExpense(data);

    success.value = "Expense submitted.";
    amount.value = "";
    category.value = "";
    description.value = "";
    currency.value = "INR";
    expenseDate.value = "";
    paidBy.value = "";
    remarks.value = "";
    receiptUrl.value = "";
    ocrText.value = "";
    emit("refresh");
  } catch (err) {
    error.value = "Failed to submit expense.";
  } finally {
    loading.value = false;
  }
};

const uploadReceipt = async (event) => {
  const file = event.target.files?.[0];
  if (!file) return;

  uploading.value = true;
  error.value = "";

  try {
    const formData = new FormData();
    formData.append("file", file);

    const res = await fetch("http://localhost:8000/expenses/upload", {
      method: "POST",
      body: formData,
    });
    const data = await res.json();
    ocrText.value = data?.raw_text || "";
    if (data?.receipt_url) {
      receiptUrl.value = data.receipt_url;
    }

    if (data?.parsed?.amount) {
      amount.value = data.parsed.amount;
    }
    if (data?.parsed?.date) {
      expenseDate.value = data.parsed.date;
    }
  } catch (err) {
    error.value = "Receipt upload failed.";
  } finally {
    uploading.value = false;
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
    <CdrInput v-model="expenseDate" label="Expense date" type="text" />
    <CdrInput v-model="paidBy" label="Paid by" />
    <CdrInput v-model="category" label="Category" />
    <CdrInput v-model="description" label="Description" />
    <CdrInput v-model="remarks" label="Remarks" />

    <div class="form-stack">
      <CdrBody class="muted">Attach receipt (OCR auto-fill)</CdrBody>
      <input type="file" @change="uploadReceipt" />
      <CdrBody v-if="uploading">Reading receipt...</CdrBody>
      <CdrBody v-else-if="ocrText">OCR detected text.</CdrBody>
    </div>

    <CdrButton :disabled="loading" @click="submitExpense">
      {{ loading ? "Submitting..." : "Submit" }}
    </CdrButton>
  </div>
</template>
