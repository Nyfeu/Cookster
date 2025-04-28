import React from 'react'
import NavBar from '../NavBar'
import SocialMediaIcons from '../AuthForm/components/SocialMediaIcons'
import './LandingPage.css'

const LandingPage = () => {
    return (
        <>
            <div className='container-page'>
                <NavBar />
                <div className="container-fluid container-home p-0 d-flex flex-column">
                    {/* Seção principal - conteúdo centralizado */}
                    <div className="flex-grow-1 d-flex align-items-center justify-content-center">
                        <div className="text-center px-4">
                            <h1 className="display-4 mb-4">Welcome to Our Website</h1>
                            <p className="lead mb-5">Discover amazing content and connect with us.</p>
                            <button type="button" className="btn btn-custom px-4 py-3">
                                Get Started
                            </button>
                        </div>
                    </div>

                    {/* Ícones de redes sociais - no final da página */}
                    <div className="text-center py-4">
                        <SocialMediaIcons />
                    </div>
                </div>
            </div>
        </>
    )
}

export default LandingPage
