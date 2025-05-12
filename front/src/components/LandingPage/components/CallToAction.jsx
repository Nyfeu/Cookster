import React from "react";
import "./CallToAction.css";

const CallToAction = () => {
    return (
        <>
            <div className="cta-wave">
                <svg viewBox="0 0 1440 320" preserveAspectRatio="none">
                    <path
                        fill="#fef6ee"
                        d="M0,160 C300,80 1140,320 1440,240 L1440,320 L0,320 Z"
                    ></path>
                </svg>
            </div>
            <section className="cta-banner py-5">
                <div className="container py-5 d-flex flex-column flex-md-row align-items-center justify-content-center gap-5">
                    <div className="cta-image text-center mx-5">
                        <img src='reg.png' alt="Pessoa cozinhando" className="img-fluid" style={{width: "100%"}}/>
                    </div>
                    <div className="cta-text mb-4 mb-md-5 text-center">
                        <h1 className="mb-3 cta-title">Pronto para transformar sua cozinha<br></br>  em um palco de histórias incríveis?</h1>
                        <p className="my-4">
                            Descubra como o Cookster pode mudar sua relação com os <br></br>ingredientes, simplificar o dia a dia e fazer <br></br>cada refeição valer a pena.
                        </p>
                        <div>
                            <button className="btn btn-custom text-white mt-3">Pronto para transformar sua cozinha?</button>
                        </div>
                    </div>
                </div>
            </section>
        </>
    );
};

export default CallToAction;
