import React from 'react'
import { Link } from 'react-router-dom';

const HeroSection = () => {
    return (
        <section id="hero-section" className="flex-grow-1 d-flex align-items-center justify-content-center">
            <div className="text-center px-4">
                <h1 className="display-4 mb-4">Bem-vindo ao Cookster</h1>
                <p className="lead mb-5">Descubra conteúdos incríveis e conecte-se com uma comunidade apaixonada pela cozinha.</p>
                <Link to='/login' type="button" className="btn btn-custom px-4 py-3">
                    Começar Agora
                </Link>
            </div>
        </section>
    )
}

export default HeroSection