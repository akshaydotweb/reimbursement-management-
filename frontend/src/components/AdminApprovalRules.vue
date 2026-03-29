<script setup>
import { ref, onMounted } from "vue";
import {
  CdrButton,
  CdrSelect,
  CdrInput,
  CdrBanner,
  CdrHeadingSans,
  CdrBody,
} from "@rei/cedar";
import {
  getApprovalRule,
  updateApprovalRule,
  getApprovalSteps,
  updateApprovalSteps,
} from "../api/api";

const users = ref([]);
const steps = ref([]);
const managerFirst = ref(true);
const percentageRequired = ref("");
const specificApproverId = ref("");
const loading = ref(false);
const success = ref("");
const error = ref("");

const loadData = async () => {
  loading.value = true;
  error.value = "";

  try {
    const [rule, stepData] = await Promise.all([
      getApprovalRule(),
      getApprovalSteps(),
    ]);
    managerFirst.value = rule.manager_first ?? true;
    percentageRequired.value = rule.percentage_required ?? "";
    specificApproverId.value = rule.specific_approver_id ?? "";
    steps.value = (Array.isArray(stepData) ? stepData : []).map((s) => ({
      approver_id: s.approver_id,
      step_order: s.step_order,
      required: s.required ?? true,
    }));

    const res = await fetch("http://localhost:8000/users", {
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${localStorage.getItem("token")}`,
      },
    });
    const userData = await res.json();
    users.value = Array.isArray(userData) ? userData : [];
  } catch (err) {
    error.value = "Unable to load approval rules.";
  } finally {
    loading.value = false;
  }
};

const addStep = () => {
  steps.value.push({
    approver_id: "",
    step_order: steps.value.length + 1,
    required: true,
  });
};

const removeStep = (index) => {
  steps.value.splice(index, 1);
  steps.value = steps.value.map((s, idx) => ({ ...s, step_order: idx + 1 }));
};

const saveRules = async () => {
  loading.value = true;
  success.value = "";
  error.value = "";

  try {
    await updateApprovalRule({
      manager_first: managerFirst.value,
      percentage_required: percentageRequired.value
        ? Number(percentageRequired.value)
        : null,
      specific_approver_id: specificApproverId.value
        ? Number(specificApproverId.value)
        : null,
    });

    const cleanedSteps = steps.value
      .filter((s) => s.approver_id)
      .map((s, idx) => ({
        approver_id: Number(s.approver_id),
        step_order: idx + 1,
        required: s.required ?? true,
      }));

    await updateApprovalSteps(cleanedSteps);
    success.value = "Approval rules updated.";
  } catch (err) {
    error.value = "Failed to update rules.";
  } finally {
    loading.value = false;
  }
};

onMounted(loadData);
</script>

<template>
  <div class="surface-card section-stack">
    <div>
      <CdrHeadingSans tag="h3" scale="1">Approval rules</CdrHeadingSans>
      <CdrBody class="muted">
        Configure approval thresholds and approver sequence.
      </CdrBody>
    </div>

    <CdrBanner v-if="success" type="success">{{ success }}</CdrBanner>
    <CdrBanner v-if="error" type="error">{{ error }}</CdrBanner>
    <CdrBody v-if="loading">Loading rules...</CdrBody>

    <div v-else class="form-stack">
      <label class="pill">
        <input type="checkbox" v-model="managerFirst" />
        <span>&nbsp;Manager approves first</span>
      </label>

      <CdrInput
        v-model="percentageRequired"
        label="Minimum approval percentage"
        type="number"
      />

      <CdrSelect v-model="specificApproverId" label="Specific approver override">
        <option value="">None</option>
        <option v-for="u in users" :key="u.id" :value="u.id">
          {{ u.email }} ({{ u.role }})
        </option>
      </CdrSelect>

      <div class="section-stack">
        <CdrBody strong>Approver sequence</CdrBody>
        <div v-for="(step, index) in steps" :key="index" class="form-stack">
          <CdrSelect v-model="step.approver_id" :label="`Approver ${index + 1}`">
            <option value="">Select approver</option>
            <option v-for="u in users" :key="u.id" :value="u.id">
              {{ u.email }} ({{ u.role }})
            </option>
          </CdrSelect>
          <label class="pill">
            <input type="checkbox" v-model="step.required" />
            <span>&nbsp;Required</span>
          </label>
          <CdrButton modifier="secondary" size="small" @click="removeStep(index)">
            Remove
          </CdrButton>
        </div>
        <CdrButton modifier="secondary" size="small" @click="addStep">
          Add approver
        </CdrButton>
      </div>

      <CdrButton :disabled="loading" @click="saveRules">
        Save rules
      </CdrButton>
    </div>
  </div>
</template>
