import React from 'react'
import '../RecipePage.css'
import { Link } from 'react-router-dom'

const RecipeInfo = () => {
  return (
    <>
        <img
                src="./receitas-salsicha.jpg"
                className="img recipe-hero-img"
                alt="recipe"
              />
              <article className="recipe-info">
                <div className='d-flex flex-collumn align-items-center'>
                <h2>Banana Pancakes</h2>
                <Link to='/profile' className='user-link'>by Lucas</Link>   
                </div>
                <p>
                  Shabby chic humblebrag banh mi bushwick, banjo kale chips
                  meggings. Cred selfies sartorial, cloud bread disrupt blue bottle
                  seitan. Dreamcatcher tousled bitters, health goth vegan venmo
                  whatever street art lyft shabby chic pitchfork beard. Drinking
                  vinegar poke tbh, iPhone coloring book polaroid truffaut tousled
                  ramps pug trust fund letterpress. Portland four loko austin
                  chicharrones bitters single-origin coffee. Leggings letterpress
                  occupy pour-over.
                </p>
                <div className="recipe-icons">
                  <article>
                    <i className="fas fa-clock"></i>
                    <h5>Tempo de Preparação</h5>
                    <p>30 min.</p>
                  </article>
                  <article>
                    <i className="far fa-clock"></i>
                    <h5>Tempo de Cozimento</h5>
                    <p>15 min.</p>
                  </article>
                  <article>
                    <i className="fas fa-user-friends"></i>
                    <h5>Porção</h5>
                    <p>6 servings</p>
                  </article>
                </div>
                <p className="recipe-tags">
                  Tags : <a href="">beef</a>
                  <a href="">breakfast</a>
                  <a href="">pancakes</a>
                  <a href="">food</a>                    
                </p>
              </article>
    </>
  )
}

export default RecipeInfo