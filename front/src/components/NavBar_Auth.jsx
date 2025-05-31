import React, { useState, useRef } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { FaUserCircle } from 'react-icons/fa';
import './NavBar.css';

const NavBar_Auth = () => {
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
                        <Link className="nav-link" to="/sobre" onClick={closeNavbar}>Despensa</Link>
                    </li>
                    <li className="nav-item">
                        <Link className="nav-link" to="/funcionalidades" onClick={closeNavbar}>Funcionalidades</Link>
                    </li>
                </ul>

                <div className="d-flex justify-content-start justify-content-lg-end w-100 px-1">
                    <Link to="/profile" onClick={closeNavbar} className="profile-icon">
                        <FaUserCircle size={28} />
                    </Link>
                </div>

            </div>
        </nav>
    );
};

export default NavBar_Auth;
