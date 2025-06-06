import React from 'react';
import { Link } from 'react-router-dom';
import { FaUserCircle } from 'react-icons/fa';
import { useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { ConfirmDialog, confirmDialog } from 'primereact/confirmdialog';
import { Toast } from 'primereact/toast';

const NavBar_Auth = () => {

    const user = JSON.parse(localStorage.getItem('user'))

    const navigate = useNavigate();
    const toast = useRef(null); 

    const confirmLogout = () => {
        confirmDialog({
            message: 'Tem certeza que deseja sair?',
            header: 'Confirmação de Saída',
            acceptLabel: 'Sim',
            rejectLabel: 'Não',
            acceptClassName: 'p-button-danger', 
            rejectClassName: 'p-button-danger',  
            
            accept: () => {
                localStorage.removeItem('token'); 
                navigate('/login'); 
            },
        });
    };

    return (
        <nav className="navbar custom-navbar px-4"> 

            <Toast ref={toast} /> 
            <ConfirmDialog className='.confirmDialog'/> 
            <Link className="navbar-brand" to="/mainpage">Cookster</Link>
            <div className="d-flex ms-auto align-items-center"> 
                <div className='mx-2 d-flex align-items-center'>
                    <a href="#" className='nav-link' onClick={confirmLogout}> 
                        Log Out
                    </a>
                </div>
                
                <Link to={`/profile/${user.id}`} className="profile-icon">
                    <FaUserCircle size={28} />
                </Link>
            </div>
        </nav>
    );
};

export default NavBar_Auth;