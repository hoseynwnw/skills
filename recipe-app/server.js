const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

let recipes = [];

app.get('/api/recipes', (req, res) => {
  res.json(recipes);
});

app.post('/api/recipes', (req, res) => {
  const recipe = req.body;
  recipes.push(recipe);
  res.status(201).json(recipe);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});