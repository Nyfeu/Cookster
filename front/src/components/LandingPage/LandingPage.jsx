import NavBar from '../NavBar'
import './LandingPage.css'
import HeroSection from './components/HeroSection'
import FeaturesSection from './components/FeatureSection'
import FooterSection from './components/FooterSection'
import CallToAction from './components/CallToAction'
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const LandingPage = () => {

    const location = useLocation();

    useEffect(() => {
        if (location.hash) {
            const element = document.getElementById(location.hash.substring(1)); // Retira o '#' da URL
            if (element) {
                element.scrollIntoView({ behavior: 'smooth' });
            }
        }
    }, [location]);

    return (
        <>
            <div className='container-page'>

                <NavBar />
                <div className="container-fluid container-home p-0 d-flex flex-column">

                    {/* Seções da Landing Page */}
                    <HeroSection />
                    <FeaturesSection />
                    <CallToAction />
                    <FooterSection />

                </div>

            </div>
        </>
    )
}

export default LandingPage
