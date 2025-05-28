import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { FaUserCircle } from 'react-icons/fa'; // Ícone de perfil
import './NavBar.css';

const NavBar = () => {

    return (
        <nav className="navbar navbar-expand-lg custom-navbar px-4">
            <Link className="navbar-brand" to="/">Cookster</Link>
            <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
                <svg xmlns="http://www.w3.org/2000/svg" width="30" height="30" fill="var(--background-color)" viewBox="0 0 16 16">
                    <path fillRule="evenodd" d="M1.5 12a.5.5 0 0 1 0-1h13a.5.5 0 0 1 0 1h-13zm0-4a.5.5 0 0 1 0-1h13a.5.5 0 0 1 0 1h-13zm0-4a.5.5 0 0 1 0-1h13a.5.5 0 0 1 0 1h-13z" />
                </svg>
            </button>


            <div className="collapse navbar-collapse" id="navbarContent">
                <ul className="navbar-nav me-auto mb-2 mb-lg-0">
                    <li className="nav-item">
                        <Link className="nav-link" to="/">Home</Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/#cta">Sobre</Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/#features">Funcionalidades</Link>
                    </li>
                </ul>
                <div className="d-flex align-items-center gap-3">
                    <Link className="btn btn-outline-primary" to="/login" state={{ mode: 'sign_in' }}>Entrar</Link>
                    <Link className="btn btn-primary" to="/register" state={{ mode: 'sign_up' }}>Registrar-se</Link>
                    <Link to="/profile"
                    >
                        <FaUserCircle style={{ color: "var(--background-color)" }} size={28} color="var(--background-color)" />
                    </Link>
                </div>
            </div>
        </nav>
    );
};

export default NavBar;
