import React from "react";
import './HeroSection.css'

export default function HeroSection() {
  return (
    <section className="hero-section py-5">
      <div className="container py-3 d-flex flex-column flex-md-row align-items-center justify-content-center gap-5">

        <div className="hero-text text-center text-md-start">
          <h1 className="fw-bold mb-4">
            Compartilhe, descubra e cozinhe junto com o mundo!
          </h1>

          <div className="d-flex flex-column flex-md-row justify-content-center justify-content-md-start gap-3">
            <button className="btn btn-custom fw-bold px-4 py-2">Ver Receitas Populares</button>
            <button className="btn btn-outline-primary fw-bold px-4 py-2">Adicionar Receita</button>
          </div>
        </div>

        <div className="hero-image text-center">
          <img
            src="hero-image-main-page-3.png"
            alt="Pessoa cozinhando"
            className="img-fluid"
            style={{ maxWidth: "400px" }}
          />
        </div>
        
      </div>
    </section>
  );
}