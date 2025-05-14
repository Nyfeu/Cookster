import React from "react";

export default function Hero() {
  return (
    <section className="hero">
      <div className="hero-text">
        <h1>Compartilhe, descubra e cozinhe junto com o mundo!</h1>
        <div className="hero-buttons">
          <button className="btn-orange">Ver Receitas Populares</button>
          <button className="btn-light">Adicionar Receita</button>
        </div>
      </div>
      <div className="hero-image">📷</div>
    </section>
  );
}
