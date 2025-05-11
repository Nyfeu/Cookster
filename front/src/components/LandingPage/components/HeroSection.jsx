import React from "react";
import "./HeroSection.css";

const HeroSection = () => {
    return (
        <>
            <section className="hero-banner py-5">
                <div className="container py-3 d-flex flex-column flex-md-row align-items-center justify-content-center gap-5">
                    <div className="hero-text mb-4 mb-md-0 text-center">
                        <h1 className="mb-3 hero-title">Porque cada ingrediente merece <br /> virar história</h1>
                        <p className="my-4">
                            Gerencie sua despensa, descubra receitas incríveis e compartilhe <br /> momentos que começam na sua cozinha.
                        </p>
                        <div>
                            <button className="btn btn-custom text-white">Comece agora</button>
                            <button className="btn btn-link text-dark">Explorar receitas</button>
                        </div>
                    </div>
                    <div className="hero-image text-center mx-5">
                        <img src='hero-banner.png' alt="Pessoa cozinhando" className="img-fluid" />
                    </div>
                </div>

            </section>
            <div className="hero-wave">
                <svg viewBox="0 0 1440 320" preserveAspectRatio="none">
                    <path
                        fill="#fef6ee"
                        d="M0,160 C300,80 1140,320 1440,240 L1440,320 L0,320 Z"
                    ></path>
                </svg>
            </div>
        </>
    );
};

export default HeroSection;
