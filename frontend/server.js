const express = require("express");
const axios = require("axios");
const dotenv = require("dotenv");

const app = express();
dotenv.config();

const PORT = process.env.PORT || 3000;
const API_URL = process.env.BACKEND_URL;

app.set("view engine", "ejs");
app.use(express.static("public"));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", async (req, res) => {
  try {
    const response = await axios.get(`${API_URL}/todos`);
    res.render("index", { todos: response.data });
  } catch (error) {
    console.error("Error fetching todos", error);
    res.render("index", { todos: [] });
  }
});

// Add a new todo
app.post("/add", async (req, res) => {
  const { task } = req.body;
  try {
    await axios.post(`${API_URL}/todos`, { task });
    res.redirect("/");
  } catch (error) {
    console.error("Error adding todo", error);
    res.redirect("/");
  }
});

// Mark a todo as done
app.post("/done/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await axios.put(`${API_URL}/todos/${id}`);
    res.redirect("/");
  } catch (error) {
    console.error("Error updating todo", error);
    res.redirect("/");
  }
});

// Delete a todo
app.post("/delete/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await axios.delete(`${API_URL}/todos/${id}`);
    res.redirect("/");
  } catch (error) {
    console.error("Error deleting todo", error);
    res.redirect("/");
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
