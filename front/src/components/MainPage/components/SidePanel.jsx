import React, { useState, useEffect } from "react";
import "./SidePanel.css";

export default function SidePanel({ show, onClose, ingredientes, setIngredientes, onPantryChange }) {
  const [searchTerm, setSearchTerm] = useState("");
  const [sugestoes, setSugestoes] = useState([]);

  // This useEffect fetches suggestions based on searchTerm
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

  // *** NEW useEffect to ensure ingredients are rendered when panel opens ***
  // This useEffect will run when the 'show' prop changes.
  // When 'show' becomes true, it effectively re-renders the component with the
  // latest 'ingredientes' prop passed from DespensaSection.
  useEffect(() => {
    if (show) {
      // You don't need to fetch again here because DespensaSection already fetches
      // and sets 'ingredientes' before 'showPanel' is set to true.
      // However, if you wanted to guarantee a fresh fetch *every time* the panel opens,
      // regardless of whether DespensaSection fetched them, you could add it here.
      // For now, simply relying on the prop is sufficient given your current setup.
      console.log("SidePanel opened. Current ingredients:", ingredientes);
    }
  }, [show, ingredientes]); // Depend on 'show' and 'ingredientes'

  const adicionarIngrediente = async (ingrediente) => {
    const token = localStorage.getItem("token");

    if (!ingrediente || !ingrediente.nome || !ingrediente.categoria) {
      console.error("Dados do ingrediente inválidos para adicionar.");
      return;
    }

    try {
      const res = await fetch("http://localhost:2000/pantry/ingredients", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(ingrediente),
      });

      if (!res.ok) {
        const errorData = await res.json();
        console.error("Erro ao adicionar ingrediente:", errorData.error || "Erro desconhecido");
        return;
      }

      const novaListaDeIngredientes = await res.json();
      setIngredientes(novaListaDeIngredientes);
      if (onPantryChange) onPantryChange();

      setSearchTerm("");
      setSugestoes([]);
    } catch (err) {
      console.error("Erro geral na requisição de adicionar ingrediente:", err);
    }
  };

  const removerIngrediente = async (ingredienteParaRemover) => {
    const token = localStorage.getItem("token");

    if (!ingredienteParaRemover || !ingredienteParaRemover.nome) {
      console.error("Nome do ingrediente inválido para remover.");
      return;
    }

    const body = {
      nome: ingredienteParaRemover.nome,
      categoria: ingredienteParaRemover.categoria,
    };

    try {
      const res = await fetch("http://localhost:2000/pantry/ingredients", {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errorData = await res.json();
        console.error("Erro ao remover ingrediente:", errorData.error || "Erro desconhecido");
        return;
      }

      const listaAtualizadaLocalmente = ingredientes.filter(
        (ing) => !(ing.nome === ingredienteParaRemover.nome && ing.categoria === ingredienteParaRemover.categoria)
      );
      setIngredientes(listaAtualizadaLocalmente);
      if (onPantryChange) onPantryChange();

      console.log(`Ingrediente '${ingredienteParaRemover.nome}' removido com sucesso!`);
    } catch (err) {
      console.error("Erro geral na requisição de remover ingrediente:", err);
    }
  };

  const agrupadoPorCategoria = (ingredientes || []).reduce((acc, item) => {
    const cat = item.categoria || "Outros";
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(item);
    return acc;
  }, {});

  const categoriasOrdenadas = Object.keys(agrupadoPorCategoria).sort((a, b) => {
    if (a === "Outros") return 1;
    if (b === "Outros") return -1;
    return a.localeCompare(b);
  });

  return (
    <div className={`side-panel ${show ? "open" : ""}`}>
      <button className="close-btn" onClick={onClose}>
        ×
      </button>
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

      {categoriasOrdenadas.map((categoria, idx) => {
        const itemsOrdenados = [...agrupadoPorCategoria[categoria]].sort((a, b) =>
          a.nome.localeCompare(b.nome)
        );

        return (
          <div key={categoria} className={`categoria-section mb-4 ${idx !== 0 ? "com-linha" : ""}`}>
            <h6 className="text-uppercase fw-bold">{categoria}</h6>
            <ul className="list-unstyled">
              {itemsOrdenados.map((item, index) => (
                <li
                  key={index}
                  className="ingredient-item"
                  onClick={() => removerIngrediente(item)}
                  style={{ cursor: "pointer" }}
                >
                  {item.nome}
                </li>
              ))}
            </ul>
          </div>
        );
      })}
    </div>
  );
}