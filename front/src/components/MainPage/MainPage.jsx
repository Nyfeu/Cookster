import React from "react";
import NavBar from "../NavBar";
import "./MainPage.css";

export default function MainPage() {
  return (
    <div className="container" style={{ paddingTop: '7vh' }}>
      <NavBar />

      <section className="hero">
        <div className="hero-text">
          <h1>Compartilhe, descubra e cozinhe junto com o mundo</h1>
          <div className="hero-buttons">
            <button className="btn-orange">Ver Receitas Populares</button>
            <button className="btn-light">Adicionar Receita</button>
          </div>
        </div>
        <div className="hero-image">📷</div>
      </section>

      <section className="despensa">
        <h2>Sua Despensa</h2>
        <button className="btn-yellow">Gerenciar Despensa</button>
        <div className="ingredientes">
          <div className="ingrediente">🍅</div>
          <div className="ingrediente">🥕</div>
          <div className="ingrediente">🥦</div>
          <div className="ingrediente">🍞</div>
        </div>
        <p>Lorem ipsum dolor sit amet, consectetur.</p>
      </section>

      <section className="feed">
        <h2>Feed de Receitas</h2>
        <div className="carousel">
          <button className="arrow">←</button>
          <div className="card">
            <div className="recipe-image">📷</div>
            <h3>Título</h3>
            <p>Descrição da publicação</p>
            <div className="actions">
              <button>❤️</button>
              <button>💬</button>
              <button>🔖</button>
              <button>🔗</button>
            </div>
            <div className="username">@Username</div>
          </div>
          <div className="card">
            <div className="recipe-image">📷</div>
            <h3>Título</h3>
            <p>Descrição da publicação</p>
            <div className="actions">
              <button>❤️</button>
              <button>💬</button>
              <button>🔖</button>
              <button>🔗</button>
            </div>
            <div className="username">@Username</div>
          </div>
          <div className="card">
            <div className="recipe-image">📷</div>
            <h3>Título</h3>
            <p>Descrição da publicação</p>
            <div className="actions">
              <button>❤️</button>
              <button>💬</button>
              <button>🔖</button>
              <button>🔗</button>
            </div>
            <div className="username">@Username</div>
          </div>
          <button className="arrow">→</button>
        </div>
      </section>

      <footer>
        <p>© 2025 Cookster, Inc. All rights reserved.</p>
        <button className="btn-green">Ícones das Redes Sociais</button>
      </footer>
    </div>
  );
}
