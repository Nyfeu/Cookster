import React, { useState, useEffect } from "react";
import "./SidePanel.css";

export default function SidePanel({ show, onClose, ingredientes, setIngredientes }) {
  const [searchTerm, setSearchTerm] = useState("");
  const [sugestoes, setSugestoes] = useState([]);

  useEffect(() => {
    const fetchSugestoes = async () => {
      if (searchTerm.trim().length < 2) {
        setSugestoes([]);
        return;
      }

      try {
        const res = await fetch(`http://localhost:8000/sugestoes?termo=${encodeURIComponent(searchTerm)}`);
        const data = await res.json();
        setSugestoes(data.sugestoes || []);
      } catch (err) {
        console.error("Erro ao buscar sugestões:", err);
        setSugestoes([]);
      }
    };

    fetchSugestoes();
  }, [searchTerm]);

  const adicionarIngrediente = async (ingrediente) => {
    const token = localStorage.getItem("token");

    try {
      const res = await fetch("http://localhost:4000/ingredients", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(ingrediente),
      });

      if (!res.ok) {
        const erro = await res.json();
        console.error("Erro ao adicionar ingrediente:", erro.error);
        return;
      }

      const atualizada = await fetch("http://localhost:4000/ingredients", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const novaLista = await atualizada.json();
      setIngredientes(novaLista);

      // 🧼 Limpa a barra e fecha o dropdown
      setSearchTerm("");      // limpa input
      setSugestoes([]);       // esconde dropdown

    } catch (err) {
      console.error("Erro geral:", err);
    }
  };

  const agrupadoPorCategoria = (ingredientes || []).reduce((acc, item) => {
    const cat = item.categoria || "Outros";
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(item);
    return acc;
  }, {});

  return (
    <div className={`side-panel ${show ? "open" : ""}`}>
      <button className="close-btn" onClick={onClose}>×</button>
      <h4 className="mb-3">Sua Despensa</h4>

      <div className="search-wrapper mb-1">
        <i className="pi pi-search search-icon" />
        <input
          type="text"
          className="form-control search-bar"
          placeholder="Buscar ingrediente..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {sugestoes.length > 0 && (
        <ul className="dropdown-menu show w-100 mt-0 position-static shadow">
          {sugestoes.map((item, index) => (
            <li
              key={index}
              className="dropdown-item d-flex align-items-center"
              onClick={() => {
                setSearchTerm("");
                setSugestoes([]);
                adicionarIngrediente(item);
              }}
              style={{ cursor: "pointer" }}
            >
              <i className="pi pi-plus me-2"></i>
              <span>
                {item.nome} <small className="text-muted">({item.categoria})</small>
              </span>
            </li>
          ))}
        </ul>
      )}

      {Object.entries(agrupadoPorCategoria).map(([categoria, items], idx) => (
        <div key={categoria} className={`categoria-section mb-4 ${idx !== 0 ? "com-linha" : ""}`}>
          <h6 className="text-uppercase fw-bold">{categoria}</h6>
          <ul className="list-unstyled">
            {items.map((item, index) => (
              <li key={index} className="ingredient-item">
                {item.nome}
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}
