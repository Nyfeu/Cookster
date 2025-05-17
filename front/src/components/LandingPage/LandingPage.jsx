import NavBar from '../NavBar'
import './LandingPage.css'
// import HeroSection from './components/HeroSection'
// import FeaturesSection from './components/FeatureSection'
// import FooterSection from './components/FooterSection'
// import CallToAction from './components/CallToAction'

const LandingPage = () => {
    return (
        <>
            <div className="container-page">

                <NavBar />
                <div className="container-fluid container-home p-0 d-flex flex-column">

                    {/* Seções da Landing Page */}
                    {/* <HeroSection />
                    <FeaturesSection />
                    <CallToAction />
                    <FooterSection /> */}

                </div>

            </div>
        </>
    )
}

export default LandingPage
