import React from "react";
import "./SidePanel.css";

export default function SidePanel({ show, onClose, ingredientes }) {
  // Agrupar por categoria
  const agrupadoPorCategoria = ingredientes?.reduce((acc, item) => {
    const cat = item.categoria || "Outros";
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(item);
    return acc;
  }, {}) || {};

  return (
    <div className={`side-panel ${show ? "open" : ""}`}>
      <button className="close-btn" onClick={onClose}>×</button>
      <h4 className="mb-3">Sua Despensa</h4>

      {Object.entries(agrupadoPorCategoria).map(([categoria, items], idx) => (
        <div key={categoria} className={`categoria-section mb-4 ${idx !== 0 ? "com-linha" : ""}`}>
          <h6 className="text-uppercase fw-bold">{categoria}</h6>
          <ul className="list-unstyled">
            {items.map((item, index) => (
              <li
                key={index}
                className="ingredient-item"
                onClick={() => console.log("Clicou:", item)}
              >
                {item.nome}
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}
