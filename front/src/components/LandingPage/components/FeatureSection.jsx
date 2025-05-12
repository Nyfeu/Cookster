import React from 'react';
import './FeatureSection.css';
import { FeatureCard } from './FeatureCard';

const FeaturesSection = () => {
  return (
    <section id="features" className="text-center">
      <div className="container">
        <h2 className="display-4 mb-5 text-feature">Funcionalidades</h2>
        <div className="row">
          <FeatureCard 
            title="Despensa Inteligente" 
            src="cesta.png"
            alt="Imagem de despensa inteligente"
            text="Controle seus ingredientes e mantenha sua despensa sempre atualizada com facilidade."
          />
          <FeatureCard 
            title="Receitas Personalizadas" 
            src="pan.png"
            alt={"Imagem de receitas personalizadas"}
            text="Descubra receitas adaptadas aos ingredientes que você já possui."
          />
          <FeatureCard 
            title="Consumo Consciente" 
            src="consumo.png"
            alt="Imagem de consumo consciente"
            text="Evite o desperdício de alimentos e aprenda a usar tudo o que tem na sua cozinha."
          />
          <FeatureCard 
            title="Rede de Receitas"
            src="social.png"
            alt={"Imagem de rede social de receitas"}
            text="Compartilhe suas receitas e descubra novas criações de outros usuários." 
          />
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
