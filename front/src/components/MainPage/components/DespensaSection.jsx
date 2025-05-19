import React from "react";
import './DespensaSection.css'

export default function DespensaSection() {
  return (
    <>
      <section className="despensa-section py-5 text-center">
        <div className="container px-3">
          <div className="row align-items-start justify-content-between text-start">

            <div className="col-md-6 mb-4">
              <h2 className="fw-bold mb-4">Sua Despensa</h2>
              <button className="btn btn-custom">Gerenciar Despensa</button>
            </div>

            <div className="col-md-6">
              <div className="d-flex justify-content-center flex-wrap gap-3 mb-3">
                <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🍅 Tomate</span>
                <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🥕 Cenoura</span>
                <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🥦 Brócolis</span>
                <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🍞 Pão</span>
              </div>
              <p className="text-muted text-center">Organize seus ingredientes para descobrir novas receitas!</p>
            </div>

          </div>
        </div>
      </section>
    </>
  );
}