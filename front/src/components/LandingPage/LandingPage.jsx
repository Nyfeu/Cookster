import React from 'react'
import NavBar from '../NavBar'
import SocialMediaIcons from '../AuthForm/components/SocialMediaIcons'
import './LandingPage.css'
import HeroSection from './components/HeroSection'
import FeaturesSection from './components/FeatureSection'
import FooterSection from './components/FooterSection'

const LandingPage = () => {
    return (
        <>
            <div className='container-page'>

                <NavBar />
                <div className="container-fluid container-home p-0 d-flex flex-column">

                    {/* Seções da Landing Page */}
                    <HeroSection />
                    <FeaturesSection />
                    <FooterSection />

                </div>

            </div>
        </>
    )
}

export default LandingPage
