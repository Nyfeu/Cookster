import React from "react";

export default function Feed() {
  return (
    <section className="feed">
      <h2>Feed de Receitas</h2>
      <div className="carousel">
        <button className="arrow">←</button>

        {[1, 2, 3, 4, 5].map((_, index) => (
          <div className="recipe-card" key={index}>
            <div className="recipe-image">📷</div>
            <h3>Título</h3>
            <p>Descrição da publicação</p>
            <div className="actions">
              <button>❤️</button>
              <button>💬</button>
              <button>🔖</button>
              <button>🔗</button>
            </div>
            <div className="username">@Username</div>
          </div>
        ))}

        <button className="arrow">→</button>
      </div>
    </section>
  );
}
