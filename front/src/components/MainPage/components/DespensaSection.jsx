// DespensaSection.jsx
import React, { useState } from "react";
import './DespensaSection.css';
import SidePanel from "./SidePanel";

export default function DespensaSection({ onPantryChange }) {
  const [showPanel, setShowPanel] = useState(false);
  const [ingredientes, setIngredientes] = useState([]);

  const fetchAndTogglePantry = async () => {
    
    if (showPanel) {
      setShowPanel(false);
      return; 
    }
    const token = localStorage.getItem("token");

    if (!token) {
      console.error("Token não encontrado. Usuário pode não estar autenticado.");
      return;
    }

    try {
      const res = await fetch("http://localhost:2000/pantry/ingredients", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        
        const errorText = await res.text(); 
        console.error("Erro ao buscar ingredientes:", res.status, errorText);
        setIngredientes([]);
        return; 

      }

      const data = await res.json();
      setIngredientes(data); 
      setShowPanel(true);    
      console.log("Ingredientes carregados na DespensaSection:", data);
    } catch (err) {
      console.error("Erro ao buscar ingredientes:", err);
      setIngredientes([]); 
    }
  };

  return (
    <section className="despensa-section py-5 text-center">
      <div className="container px-3 mb-4 mt-5">
        <div className="row align-items-start justify-content-between">
          <div className="col-md-6 pb-5">
            <h2 className="mb-3">Sua Despensa</h2>
            <button className="btn btn-custom" onClick={fetchAndTogglePantry}> 
              Gerenciar Despensa
            </button>

            <SidePanel
              show={showPanel}
              onClose={() => setShowPanel(false)}
              ingredientes={ingredientes} 
              setIngredientes={setIngredientes} 
              onPantryChange={onPantryChange}
            />
          </div>

          <div className="col-md-6">
            <p className="text-center">Organize seus ingredientes para descobrir novas receitas!</p>
            <div className="d-flex justify-content-center flex-wrap gap-3 mb-3">
              <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🍅 Tomate</span>
              <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🥕 Cenoura</span>
              <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🥦 Brócolis</span>
              <span className="badge bg-secondary rounded-pill px-3 py-2 fs-5">🍞 Pão</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}