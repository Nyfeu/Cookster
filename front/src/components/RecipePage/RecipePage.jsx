/* eslint-disable no-unused-vars */
import React, { Component } from 'react'
import './RecipePage.css'
import NavBar_Auth from '../NavBar_Auth'
import RecipeInfo from './componentes/RecipeInfo'
import IngredientsInfo from './componentes/IngredientsInfo'
import ToolsInfo from './componentes/ToolsInfo'
import InstructionsInfo from './componentes/InstructionsInfo'
import { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom';

const RecipePage = () => {

  const [userId, setUserId] = useState(null);
  const [name, setName] = useState(null);
  const [description, setDescription] = useState(null);
  const [prepTime, setPrepTime] = useState(null);
  const [cookTime, setCookTime] = useState(null);
  const [totalTime, setTotalTime] = useState(null);
  const [servings, setServings] = useState(null);
  const [tags, setTags] = useState([]); 
  const [steps, setSteps] = useState([]); 
  const [ingredients, setIngredients] = useState([]); 
  const [utensils, setUtensils] = useState([]); 
  const [imageUrl, setImageUrl] = useState(null);
  const [recipeData, setRecipeData] = useState()

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const { idReceita } = useParams();
 

  useEffect(() => {
    console.log(idReceita)
    const fetchRecipe = async () => {
      if (!idReceita) {
        setError("ID da receita não encontrado na URL.");
        setLoading(false);
        return;
      }

      try {
        
        setLoading(true);
        setError(null);

        const token = localStorage.getItem("token");

        if (!token) {
          console.error("Token não encontrado. Usuário pode não estar autenticado.");
          return;
        }

        const response = await fetch(`http://localhost:2000/recipe/recipes/${idReceita}`, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${token}`
                    }
                });
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.message || `Erro HTTP: ${response.status}`);
        }

        const data = await response.json();
        setRecipeData(data); 
      } catch (err) {
        console.error("Erro ao buscar receita:", err);
        setError(err.message || "Erro desconhecido ao carregar a receita.");
        setRecipeData(null);
      } finally {
        setLoading(false);
      }
    };

    fetchRecipe();
  }, [idReceita]);

  useEffect(() => {
        if (recipeData) {
            setUserId(recipeData.user_id);
            setName(recipeData.name);
            setDescription(recipeData.description);
            setPrepTime(recipeData.prep_time);
            setCookTime(recipeData.cook_time);
            setTotalTime(recipeData.total_time);
            setServings(recipeData.servings);
            setTags(recipeData.tags);
            setSteps(recipeData.steps);
            setIngredients(recipeData.ingredients);
            setUtensils(recipeData.utensils);
            setImageUrl(recipeData.image_url);
        }
    }, [recipeData]);

  if (loading) {
    return <p>Carregando receita...</p>;
  }

  if (error) {
    return <p style={{ color: 'red' }}>Erro: {error}</p>;
  }

  if (!recipeData) {
    return <p>Receita não encontrada.</p>;
  }

  console.log(recipeData)

  return (
    <div>
      <div className="nav">
        <NavBar_Auth />
      </div>
      <main className="page">

        <div className="recipe-page">
          <section className="recipe-hero">
            <RecipeInfo 
              name = {name}
              description = {description}
              prep_time = {prepTime}
              cook_time = {cookTime}
              serving= {servings}
              imageUrl = {imageUrl}
            />
          </section>

          <section className="recipe-content">
            <article>
              <InstructionsInfo 
              steps={steps}/>
            </article>
            <article className="second-column">
              <div className="ingredients">
                <IngredientsInfo 
                ingredients={ingredients}/>
              </div>
              <div className="tools">
                <ToolsInfo 
                utensils={utensils}/>
              </div>
            </article>
          </section>
        </div>

      </main>

    </div>
  )
}

export default RecipePage
