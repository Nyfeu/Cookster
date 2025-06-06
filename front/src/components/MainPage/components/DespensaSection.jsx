// DespensaSection.jsx
import React, { useState } from "react";
import './DespensaSection.css';
import SidePanel from "./SidePanel";

export default function DespensaSection({ onPantryChange }) {
  const [showPanel, setShowPanel] = useState(false);
  const [ingredientes, setIngredientes] = useState([]);

  // This function will be responsible for fetching the latest ingredients
  // and then toggling the panel.
  const fetchAndTogglePantry = async () => {
    // If the panel is already open, just close it.
    if (showPanel) {
      setShowPanel(false);
      return; // Exit if closing
    }

    // If the panel is closed, proceed to fetch and then open.
    const token = localStorage.getItem("token");

    if (!token) {
      console.error("Token não encontrado. Usuário pode não estar autenticado.");
      // Optionally, redirect to login or show a message
      return;
    }

    try {
      const res = await fetch("http://localhost:2000/pantry/ingredients", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        // Handle HTTP errors (e.g., 401 Unauthorized, 404 Not Found)
        const errorText = await res.text(); // Get raw error message
        console.error("Erro ao buscar ingredientes:", res.status, errorText);
        // Depending on the error, you might want to set ingredientes to an empty array
        setIngredientes([]);
        return; // Stop execution if there's an error
      }

      const data = await res.json();
      setIngredientes(data); // <--- Update state with fetched ingredients
      setShowPanel(true);    // <--- ONLY THEN, open the panel
      console.log("Ingredientes carregados na DespensaSection:", data);
    } catch (err) {
      console.error("Erro ao buscar ingredientes:", err);
      setIngredientes([]); // Clear ingredients on error
    }
  };

  // You also need to pass the setIngredientes function to SidePanel
  // so it can update the list when adding/removing ingredients.
  return (
    <section className="despensa-section py-5 text-center">
      <div className="container px-3 mb-4 mt-5">
        <div className="row align-items-start justify-content-between">
          <div className="col-md-6 pb-5">
            <h2 className="mb-3">Sua Despensa</h2>
            <button className="btn btn-custom" onClick={fetchAndTogglePantry}> {/* Use the new function */}
              Gerenciar Despensa
            </button>

            <SidePanel
              show={showPanel}
              onClose={() => setShowPanel(false)}
              ingredientes={ingredientes} // Pass the state
              setIngredientes={setIngredientes} // Pass the setter
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