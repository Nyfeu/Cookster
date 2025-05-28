import { useState } from 'react'
import SocialMediaIcons from './SocialMediaIcons';
import { useNavigate } from 'react-router-dom';

const SignInForm = (props) => {

    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState(null);
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null);

        try {
            const response = await fetch('http://localhost:3000/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email, password })
            });

            const data = await response.json();

            if (!response.ok) {
                setError(data.error || 'Erro ao fazer login');
                return;
            }

            // Salvar o token (pode usar localStorage, sessionStorage ou cookies)
            localStorage.setItem('token', data.token);
            // Redirecionar ou atualizar o estado do app
            alert('Login bem-sucedido!');
            // props.onLoginSuccess?.(data.user); // caso deseje notificar o App principal
            console.log(localStorage.getItem('token'))
            navigate('/profile', { state: { token: localStorage.getItem('token')} });

        } catch (err) {
            setError('Erro de conexão com o servidor');
            console.error('Erro:', err);
        }
    };

    return (
        <>
            <form onSubmit={handleSubmit} className="sign-in-form">
                <h2 className="title mb-3">Acesse</h2>
                <div className="input-field">
                    <i className="fas fa-envelope"></i>
                    <input 
                        type="text" 
                        placeholder={props.email_placeholder}
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                    />
                </div>
                <div className="input-field">
                    <i className="fas fa-lock"></i>
                    <input 
                        type="password"
                        placeholder={props.password_placeholder}
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                    />
                </div>
                <input type="submit" className="btn btn-success btn-submit rounded-pill px-4 py-2 my-2" />
                {error && <p className="text-danger mt-2">{error}</p>}
                <p className="social-text">{props.text}</p>
                <SocialMediaIcons />
            </form>
        </>
    )
}

export default SignInForm