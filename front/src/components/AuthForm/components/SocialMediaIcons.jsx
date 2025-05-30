import React from 'react';

const SocialMediaIcons = () => {
    
    const BACKEND_URL = 'http://localhost:3000'; 

    return (
        <div className="social-media">
            <a href={`${BACKEND_URL}/auth/facebook`} className="social-icon">
                <i className="fab fa-facebook-f"></i>
            </a>
            <a href="#" className="social-icon">
                <i className="fab fa-twitter"></i>
            </a>
            <a href={`${BACKEND_URL}/auth/google`} className="social-icon">
                <i className="fab fa-google"></i>
            </a>
            <a href="#" className="social-icon">
                <i className="fab fa-linkedin-in"></i>
            </a>
        </div>
    )
};

export default SocialMediaIcons;
