import React from "react";
import './DespensaSection.css'

export default function DespensaSection() {
  return (
    <section className="despensa-section py-5 text-center">
      <div className="px-3">
        <h2 className="fw-bold mb-4">Sua Despensa</h2>
        <button className="btn btn-custom mb-4">Gerenciar Despensa</button>
        <div className="d-flex justify-content-center flex-wrap gap-3 mb-3">
          <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🍅 Tomate</span>
          <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🥕 Cenoura</span>
          <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🥦 Brócolis</span>
          <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🍞 Pão</span>
        </div>
        <p className="text-muted">Organize seus ingredientes para descobrir novas receitas!</p>
      </div>
    </section>
  );
}