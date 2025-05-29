import React, { useState, useEffect } from "react";
import './DespensaSection.css';
import SidePanel from "./SidePanel";

export default function DespensaSection() {

  const [showPanel, setShowPanel] = useState(false);
  const [ingredientes, setIngredientes] = useState([]);

  const abrirDespensa = async () => {
    console.log("abrindo painel...");
    try {
      const data = [
        { nome: "Tomate", categoria: "Legumes" },
        { nome: "Cenoura", categoria: "Legumes" },
        { nome: "Arroz", categoria: "Grãos" },
        { nome: "Feijão", categoria: "Grãos" },
        { nome: "Sal", categoria: "Temperos" }
      ];
      setIngredientes(data);
      setShowPanel(true);
    } catch (err) {
      console.error("Erro ao buscar ingredientes:", err);
    }
  };

  return (
    <>
      <section className="despensa-section py-5 text-center">
        <div className="container px-3 mb-4 mt-5">
          <div className="row align-items-start justify-content-between text-start">

            <div className="col-md-6 mb-4">
              <h2 className="mb-4">Sua Despensa</h2>
              <button className="btn btn-custom" onClick={abrirDespensa}>Gerenciar Despensa</button>
              <SidePanel 
                show={showPanel} 
                onClose={() => setShowPanel(false)} 
                ingredientes={ingredientes} 
              />
            </div>

            <div className="col-md-6">
              <div className="d-flex justify-content-center flex-wrap gap-3 mb-3">
                <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🍅 Tomate</span>
                <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🥕 Cenoura</span>
                <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🥦 Brócolis</span>
                <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🍞 Pão</span>
              </div>
              <p className="text-center">Organize seus ingredientes para descobrir novas receitas!</p>
            </div>

          </div>
        </div>
      </section>
    </>
  );
}