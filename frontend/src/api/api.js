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
  const res = await fetch(`${BASE_URL}/users`, {
    method: "POST",
    headers: getHeaders(),
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
  const res = await fetch(`${BASE_URL}/expenses?user_id=${user_id}`, {
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

// APPROVALS
export const approveExpense = async (id, approver_id) => {
  const res = await fetch(`${BASE_URL}/approvals/${id}/approve`, {
    method: "POST",
    headers: getHeaders(),
    body: JSON.stringify({ approver_id }),
  });
  return res.json();
};

export const rejectExpense = async (id, approver_id, comment) => {
  const res = await fetch(`${BASE_URL}/approvals/${id}/reject`, {
    method: "POST",
    headers: getHeaders(),
    body: JSON.stringify({ approver_id, comment }),
  });
  return res.json();
};
