import React from 'react';

const NavBar = () => {
    return (
        <nav className="navbar navbar-light bg-light bg-dark px-3" style={{ height: '7vh', position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            zIndex: 1000 }}>
            <a className="navbar-brand text-light justify-content-center m-0" href="#">Cookster</a>
            <button className="btn btn-outline-light px-3">Entrar</button>
        </nav>
    )
};

export default NavBar;
