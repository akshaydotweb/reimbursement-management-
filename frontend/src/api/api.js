const BASE_URL = "http://localhost:8000";

const getHeaders = () => ({
  "Content-Type": "application/json",
  "Authorization": `Bearer ${localStorage.getItem("token")}`,
});

export const getAllExpenses = async () => {
  const res = await fetch("http://localhost:8000/admin/all-expenses", {
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${localStorage.getItem("token")}`,
    },
  });

  return res.json();
};

// USERS
export const createUser = async (data) => {
  const res = await fetch("http://localhost:8000/users/create-user", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${localStorage.getItem("token")}`,
    },
    body: JSON.stringify(data),
  });

  return res.json();
};

// EXPENSES
export const createExpense = async (data) => {
  const res = await fetch(`${BASE_URL}/expenses/`, {
    method: "POST",
    headers: getHeaders(),
    body: JSON.stringify(data),
  });
  return res.json();
};

export const getExpenses = async (user_id) => {
  const query = user_id ? `?user_id=${user_id}` : "";
  const res = await fetch(`${BASE_URL}/expenses${query}`, {
    headers: getHeaders(),
  });
  return res.json();
};

export const getPendingExpenses = async () => {
  const res = await fetch(`${BASE_URL}/expenses/pending`, {
    headers: getHeaders(),
  });
  return res.json();
};

export const getPendingApprovals = async () => {
  const res = await fetch(`${BASE_URL}/approvals/pending`, {
    headers: getHeaders(),
  });
  return res.json();
};

export const getCurrentUser = async () => {
  const res = await fetch(`${BASE_URL}/users/me`, {
    headers: getHeaders(),
  });
  return res.json();
};

// APPROVALS
export const approveExpense = async (expenseId) => {
  const res = await fetch(`http://localhost:8000/approvals/${expenseId}`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${localStorage.getItem("token")}`,
    },
  });

  return res.json();
};

export const rejectExpense = async (id, approver_id = null, comment = "") => {
  const res = await fetch(`${BASE_URL}/approvals/${id}/reject`, {
    method: "POST",
    headers: getHeaders(),
    body: JSON.stringify({ approver_id, comment }),
  });
  return res.json();
};
