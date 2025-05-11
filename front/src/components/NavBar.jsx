import React from 'react';
import { Link } from 'react-router-dom';
import { FaUserCircle } from 'react-icons/fa'; // Ícone de perfil
import './NavBar.css'; 

const NavBar = () => {
    return (
        <nav className="navbar navbar-expand-lg custom-navbar px-4">
            <Link className="navbar-brand" to="/">Cookster</Link>
            <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
                <span className="navbar-toggler-icon"></span>
            </button>

            <div className="collapse navbar-collapse" id="navbarContent">
                <ul className="navbar-nav me-auto mb-2 mb-lg-0">
                    <li className="nav-item">
                        <Link className="nav-link" to="/">Home</Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/sobre">Sobre</Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/funcionalidades">Funcionalidades</Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/como-usar">Como usar</Link>
                    </li>
                </ul>
                <div className="d-flex align-items-center gap-3">
                    <Link className="btn btn-outline-primary" to="/login">Entrar</Link>
                    <Link className="btn btn-primary" to="/register">Registrar-se</Link>
                    <FaUserCircle style={{color: "var(--background-color)"}} size={28} color="#555" />
                </div>
            </div>
        </nav>
    );
};

export default NavBar;
