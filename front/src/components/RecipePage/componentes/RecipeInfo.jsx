import React from 'react'
import '../RecipePage.css'
import { Link } from 'react-router-dom'

const RecipeInfo = (props) => {
  return (
    <div className="recipe-hero-container"> 
      <img
        src="https://lh6.googleusercontent.com/proxy/ykA2OCzir59Xamqk1awJ_17k3uYaXNDD8NWurWhlkuZIlEqJqlI3heuFsX6MHA4FLybzFEh64l_AWWYmKkNyTyNKX1VkhyMgOvbwfljtZS3m0-lXj4OOVqRsUDjSMttIYku7kleQYwsON_dOifBk5FuXjX7iLG_xKkGxnsi7CoO4cKeDKxB4M0aK8FpCLIMq7Glbd3me" // OU {props.image_url} vindo do seu estado de receita
        className="img recipe-hero-img"
        alt="recipe"
      />

      <article className="recipe-info">
        <div className='d-flex flex-column align-items-center'> 
          <h2>{props.name}</h2>
          <Link to='/profile' className='user-link'>{props.user_id}</Link>
        </div>
        <p>{props.description}</p>
        

        <p className="recipe-tags">
          Tags : <a href="">beef</a>
          <a href="">breakfast</a>
          <a href="">pancakes</a>
          <a href="">food</a>
        </p>
      </article>

      <div className="recipe-icons-sidebar"> 
        <article>
          <i className="fas fa-clock"></i>
          <h5>Tempo de Preparação</h5>
          <p>{props.prep_time}</p>
        </article>
        <article>
          <i className="far fa-clock"></i>
          <h5>Tempo de Cozimento</h5>
          <p>{props.cook_time}</p>
        </article>
        <article>
          <i className="fas fa-user-friends"></i>
          <h5>Porção</h5>
          <p>{props.serving}</p>
        </article>
      </div>

    </div>
  )
}


export default RecipeInfo