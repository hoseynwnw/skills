document.getElementById('recipe-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const title = document.getElementById('title').value;
  const ingredients = document.getElementById('ingredients').value;
  const instructions = document.getElementById('instructions').value;
  const recipe = { title, ingredients, instructions };

  try {
    const response = await fetch('/api/recipes', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(recipe)
    });
    if (response.ok) {
      document.getElementById('recipe-form').reset();
      loadRecipes();
    } else {
      alert('Error adding recipe');
    }
  } catch (error) {
    alert('Error: ' + error.message);
  }
});

async function loadRecipes() {
  try {
    const res = await fetch('/api/recipes');
    const recipes = await res.json();
    const recipesDiv = document.getElementById('recipes');
    recipesDiv.innerHTML = '';
    recipes.forEach(recipe => {
      const div = document.createElement('div');
      div.className = 'recipe';
      div.innerHTML = `
        <h2>${recipe.title}</h2>
        <h3>Ingredients</h3>
        <p>${recipe.ingredients}</p>
        <h3>Instructions</h3>
        <p>${recipe.instructions}</p>
      `;
      recipesDiv.appendChild(div);
    });
  } catch (error) {
    console.error('Error loading recipes:', error);
  }
}

loadRecipes();