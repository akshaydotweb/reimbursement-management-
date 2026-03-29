<script setup>
import ExpenseForm from "../components/ExpenseForm.vue";
import ExpenseList from "../components/ExpenseList.vue";
import { ref } from "vue";

const refreshKey = ref(0);

const refreshList = () => {
  refreshKey.value++;
};
</script>

<template>
  <div>
    <ExpenseForm @refresh="refreshList" />
    <ExpenseList :key="refreshKey" />
  </div>
</template>