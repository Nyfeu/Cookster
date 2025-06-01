import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { FaUserCircle } from 'react-icons/fa'; // Ícone de perfil
import './NavBar.css';

const NavBar = () => {
    const [isCollapsed, setIsCollapsed] = useState(true);

    const toggleNavbar = () => {
        setIsCollapsed(!isCollapsed);
    };

    const closeNavbar = () => {
        setIsCollapsed(true);
    };

    return (
        <nav className="navbar navbar-expand-lg custom-navbar px-4">
            <Link className="navbar-brand" to="/">Cookster</Link>

            <button className="navbar-toggler" type="button" onClick={toggleNavbar}>
                <svg xmlns="http://www.w3.org/2000/svg" width="30" height="30" fill="var(--background-color)" viewBox="0 0 16 16">
                    <path fillRule="evenodd" d="M1.5 12a.5.5 0 0 1 0-1h13a.5.5 0 0 1 0 1h-13zm0-4a.5.5 0 0 1 0-1h13a.5.5 0 0 1 0 1h-13zm0-4a.5.5 0 0 1 0-1h13a.5.5 0 0 1 0 1h-13z" />
                </svg>
            </button>


            <div className={`collapse navbar-collapse ${isCollapsed ? '' : 'show'}`} id="navbarContent">
                <ul className="navbar-nav mb-2 mb-lg-0">
                    <li className="nav-item">
                        <Link className="nav-link" to="/" onClick={closeNavbar}>Home</Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/sobre">Sobre</Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/funcionalidades">Funcionalidades</Link>
                    </li>
                </ul>

                <div className="d-flex justify-content-start justify-content-lg-end w-100 px-1 gap-3">
                    <Link className="btn btn-outline-primary" to="/login" state={{ mode: 'sign_in' }}>Entrar</Link>
                    <Link className="btn btn-primary" to="/register" state={{ mode: 'sign_up' }}>Registrar-se</Link>
                </div>
            </div>
        </nav>
    );
};

export default NavBar;