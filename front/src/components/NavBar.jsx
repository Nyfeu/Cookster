import React from 'react';
import { Link } from 'react-router-dom';

const NavBar = () => {
    return (
        <nav className="navbar navbar-light bg-light bg-dark px-3" style={{
            height: '7vh', position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            zIndex: 1000
        }}>
            <a className="navbar-brand text-light justify-content-center m-0" href="#">Cookster</a>
            <div className='d-flex justify-content-end align-items-center'>
                
                <Link to="/" className="btn btn-outline-light mx-2">Home</Link>
                <Link to="/login" className="btn btn-outline-light">Entrar</Link>
            </div>
        </nav>
    )
};

export default NavBar;
