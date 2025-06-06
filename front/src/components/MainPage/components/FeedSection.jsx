import React, { useState, useEffect } from "react";
import './FeedSection.css'

export default function FeedSection() {

  const [suggestedRecipes, setSuggestedRecipes] = useState([]);

  // Função para buscar receitas sugeridas
  const fetchSuggestedRecipes = async () => {

    // Obtém o token do localStorage
    // Se o token não estiver presente, não faz a requisição e exibe um aviso

    const token = localStorage.getItem('token');
    if (!token) {
      console.warn("Token não encontrado. Não é possível buscar receitas sugeridas.");
      setSuggestedRecipes([]);
      return;
    }

    try {

      // A requisição é feita para o API Gateway.
      // O API Gateway adicionará o 'user-id' ao header para o mss-recipe.
      const response = await fetch(`http://localhost:2000/recipe/suggest`, {

        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}` //
        }

      });

      // Verifica se a resposta foi bem-sucedida
      if (!response.ok) {

        const errorData = await response.json();
        console.error("Erro ao buscar receitas sugeridas:", errorData.error || `Erro HTTP: ${response.status}`);
        setSuggestedRecipes([]);
        return;

      }

      // Se a resposta for bem-sucedida, converte o JSON e atualiza o estado
      // O mss-recipe retorna um array de receitas sugeridas
      const data = await response.json();
      setSuggestedRecipes(data);
      console.log("Receitas sugeridas carregadas:", data);

    } catch (error) {

      console.error("Erro de rede ou ao buscar receitas sugeridas:", error);
      setSuggestedRecipes([]);

    }

  };

  // O efeito roda apenas na montagem, e será re-executado quando a 'key' do componente mudar
  useEffect(() => {
    fetchSuggestedRecipes()
  }, []);

  return (
    <section className="feed-section py-5 text-center">
      <div className="px-3">
        <h2 className="text-color mb-3">Feed de Receitas</h2>
        <p className="text-muted mb-4">Confira as últimas receitas compartilhadas pela comunidade!</p>
        <div className="recipe-cards-container d-flex justify-content-center flex-wrap gap-3">
          {suggestedRecipes.length > 0 ? (
            suggestedRecipes.map((recipe, index) => (
              <div className="recipe-card" key={recipe._id || index}>
                <div className="recipe-image bg-secondary text-white d-flex align-items-center justify-content-center rounded mb-3">
                  {recipe.image_url ? (
                    <img src={recipe.image_url} alt={recipe.name} />
                  ) : (
                    '📷'
                  )}
                </div>
                <h5 className="fw-bold">{recipe.name}</h5>
                {/* Container para a descrição com altura fixa */}
                <div className="description-container">
                  <p className="text-muted small description-text">
                    {recipe.description ? recipe.description : ''}
                  </p>
                </div>
                <div className="actions d-flex justify-content-center gap-2">
                  <button className="btn btn-sm">
                    <i className="pi pi-heart fs-5"></i>
                  </button>
                  <button className="btn btn-sm">
                    <i className="pi pi-comment fs-5"></i>
                  </button>
                  <button className="btn btn-sm">
                    <i className="pi pi-bookmark fs-5"></i>
                  </button>
                  <button className="btn btn-sm">
                    <i className="pi pi-share-alt fs-5"></i>
                  </button>
                </div>
                <div className="username mt-2 text-muted small">@{recipe.user_id}</div>
              </div>
            ))
          ) : (
            <p>Nenhuma receita sugerida encontrada com os ingredientes na sua despensa.</p>
          )}
        </div>
      </div>
    </section>
  );
}