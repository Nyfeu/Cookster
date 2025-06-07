import React, { useState, useEffect } from "react";
import "./SidePanel.css";

export default function SidePanel({ show, onClose, ingredientes, setIngredientes, onPantryChange }) {

  const [searchTerm, setSearchTerm] = useState("");
  const [sugestoes, setSugestoes] = useState([]);

  useEffect(() => {

    const fetchSugestoes = async () => {

      if (searchTerm.trim().length < 2) {
        setSugestoes([]);
        return;
      }

      try {

        const token = localStorage.getItem("token");
        if (!token) {
            console.warn("Token não encontrado. Não é possível buscar sugestões.");
            setSugestoes([]);
            return;
        }

        const res = await fetch(`http://localhost:2000/ingredient/sugestoes?termo=${encodeURIComponent(searchTerm)}`, {
                headers: {
                    'Authorization': `Bearer ${token}` 
                }
            });
        
        if (!res.ok) {

                // Se a resposta não for OK, tente ler a mensagem de erro do backend
                const errorData = await res.json();
                console.error("Erro ao buscar sugestões:", errorData.error || `Erro HTTP: ${res.status}`);
                setSugestoes([]);
                return;
                
            }

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

    // Basic validation for the ingredient data
    if (!ingrediente || !ingrediente.nome || !ingrediente.categoria) {
      console.error("Dados do ingrediente inválidos para adicionar.");
      return;
    }

    try {
      // **CRITICAL FIX:** Changed port from 4000 to 6000 for your mss-pantry service
      const res = await fetch("http://localhost:2000/pantry/ingredients", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(ingrediente),
      });

      if (!res.ok) {
        // If the response is not OK, try to parse the error message from the backend
        const errorData = await res.json();
        console.error("Erro ao adicionar ingrediente:", errorData.error || "Erro desconhecido");
        return; // Stop execution if there's an error
      }

      // **OPTIMIZATION:** Your mss-pantry POST endpoint already returns the full updated list.
      // So, we use that directly instead of making another GET request.
      const novaListaDeIngredientes = await res.json();
      setIngredientes(novaListaDeIngredientes);
      if (onPantryChange) onPantryChange();

      // 🧼 Clears the search bar and hides the dropdown after adding
      setSearchTerm("");
      setSugestoes([]);

    } catch (err) {

      // Catch any network errors or issues before parsing the response
      console.error("Erro geral na requisição de adicionar ingrediente:", err);

    }

  };

  // --- NOVA FUNÇÃO PARA REMOVER INGREDIENTE ---
  const removerIngrediente = async (ingredienteParaRemover) => {
    const token = localStorage.getItem("token");

    if (!ingredienteParaRemover || !ingredienteParaRemover.nome) {
      console.error("Nome do ingrediente inválido para remover.");
      return;
    }

    // O mss-pantry permite a categoria opcional no DELETE,
    // mas é melhor enviá-la para exclusão exata se disponível.
    const body = {
      nome: ingredienteParaRemover.nome,
      categoria: ingredienteParaRemover.categoria // Envie a categoria se tiver
    };

    try {
      // ** Porta correta: 3001 para o mss-pantry DELETE **
      const res = await fetch("http://localhost:2000/pantry/ingredients", {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(body), // Corpo com nome e categoria
      });

      if (!res.ok) {
        const errorData = await res.json();
        console.error("Erro ao remover ingrediente:", errorData.error || "Erro desconhecido");
        return;
      }

      // Se a remoção foi bem-sucedida, atualize a lista localmente
      // Você pode refazer um GET para ter a lista mais recente, ou
      // filtrar localmente se tiver certeza que o backend está consistente.
      // Optamos por filtrar localmente para otimizar, como o backend já valida a remoção.
      const listaAtualizadaLocalmente = ingredientes.filter(ing =>
        !(ing.nome === ingredienteParaRemover.nome && ing.categoria === ingredienteParaRemover.categoria)
      );
      setIngredientes(listaAtualizadaLocalmente);
      if (onPantryChange) onPantryChange();

      // Opcional: feedback visual de sucesso
      console.log(`Ingrediente '${ingredienteParaRemover.nome}' removido com sucesso!`);

    } catch (err) {

      console.error("Erro geral na requisição de remover ingrediente:", err);

    }
    
  };

  // const ingredientesValidos = Array.isArray(ingredientes) ? ingredientes : [];

  // This grouping logic is already correct and will display categories
  const agrupadoPorCategoria = (ingredientes || []).reduce((acc, item) => {
    const cat = item.categoria || "Outros"; // Ensures ingredients without a category fall into "Outros"
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
                // When an item is clicked, add it and clear the search/suggestions
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
              {itemsOrdenados.map((item, index) => ( // Usar itemsOrdenados aqui
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