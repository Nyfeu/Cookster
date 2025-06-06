import React from "react"; // Removed useRef as it's no longer needed
import './FeedSection.css'

export default function FeedSection() {
  // Removed carouselRef and scrollLeft/scrollRight functions as they are no longer needed

  return (
    <section className="feed-section py-5 text-center">
      <div className="px-3">
        <h2 className="text-color mb-3">Feed de Receitas</h2>
        <p className="text-muted mb-4">Confira as últimas receitas compartilhadas pela comunidade!</p>
        {/* Removed the carousel controls (arrows) */}
        {/* Adjusted the main container for recipe cards */}
        <div className="recipe-cards-container d-flex justify-content-center flex-wrap gap-3">
          {[1, 2, 3, 4, 5].map((_, index) => (
            <div className="recipe-card" key={index}>
              <div className="recipe-image bg-secondary text-white d-flex align-items-center justify-content-center rounded mb-3" style={{ height: '120px' }}>📷</div>
              <h5 className="fw-bold">Título da Receita</h5>
              <p className="text-muted small">Descrição da publicação</p>
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
              <div className="username mt-2 text-muted small">@Username</div>
            </div>
          ))}
        </div>
        {/* Removed the right arrow button */}
      </div>
    </section>
  );
}