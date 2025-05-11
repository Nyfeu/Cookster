import React from 'react';
import './FeatureSection.css';

const FeaturesSection = () => {
  return (
    <section id="features" className="text-center">
      <div className="container">
        <h2 className="display-4 mb-5 text-feature">Features</h2>
        <div className="row">
          <div className="col-md-4">
            <h4 className='text-feature'>Organize sua Despensa</h4>
            <p className='text-feature'>Controle seus ingredientes e mantenha sua despensa sempre atualizada com facilidade.</p>
          </div>
          <div className="col-md-4">
            <h4 className='text-feature'>Descubra Receitas Personalizadas</h4>
            <p className='text-feature'>Receba sugestões de receitas baseadas nos itens que você já possui em casa.</p>
          </div>
          <div className="col-md-4">
            <h4 className='text-feature'>Conecte-se com a Comunidade</h4>
            <p className='text-feature'>Compartilhe suas receitas favoritas, avalie dicas culinárias e inspire-se com outros amantes da cozinha.</p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
