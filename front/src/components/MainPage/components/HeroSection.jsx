import React from "react";
import './HeroSection.css'

export default function HeroSection() {
  return (
    <section 
    className="hero-banner py-5 d-flex align-items-start text-left" 

    style={{ backgroundColor: "var(--background-color)" }}>
      
      <div className="py-5">
        <h1 className="fw-bold text-color mb-4">Compartilhe, descubra e cozinhe junto com o mundo!</h1>
        <div className="d-flex flex-column flex-md-row justify-content-center gap-3">
          <button className="btn btn-custom">Ver Receitas Populares</button>
          <button className="btn btn-outline-primary">Adicionar Receita</button>
        </div>
      </div>
    </section>
  );
}
