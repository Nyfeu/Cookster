import React, { Component } from 'react'
import './RecipePage.css'
import NavBar from '../NavBar'
import RecipeInfo from './componentes/RecipeInfo'
import IngredientsInfo from './componentes/IngredientsInfo'
import ToolsInfo from './componentes/ToolsInfo'
import InstructionsInfo from './componentes/InstructionsInfo'

export default class RecipePage extends Component {
  render() {
    return (
        <div>
            <div className="nav">
            <NavBar />
            </div>

        <main className="page">
          <div className="recipe-page">
            <section className="recipe-hero">
              <RecipeInfo />
            </section>
  
            <section className="recipe-content">
              <article>
                <InstructionsInfo />
              </article>
              <article className="second-column">
                <div className="ingredients">
                <IngredientsInfo />
                </div>
                <div className="tools">
                  <ToolsInfo />
                </div>
              </article>
            </section>
          </div>
          
        </main>
  
      </div>
    )
  }
}
