import { useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';

const AuthSuccess = () => {
    const navigate = useNavigate();
    const hasProcessed = useRef(false); 

    useEffect(() => {
        if (hasProcessed.current) return; 
        hasProcessed.current = true;

        const params = new URLSearchParams(window.location.search);
        const token = params.get('token');
        const name = params.get('name');
        const email = params.get('email');

        console.log("Token:", token);
        console.log("Name:", name);
        console.log("Email:", email);

        if (token) {
            localStorage.setItem('token', token);
            alert(`Bem-vindo, ${name || 'usuário'}!`);
            navigate('/login'); 
        } else {
            alert('Erro ao autenticar com rede social.');
            navigate('/login');
        }
    }, [navigate]);

    return <p>Autenticando...</p>;
};

export default AuthSuccess;
