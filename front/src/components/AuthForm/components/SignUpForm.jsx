import { useState } from 'react'
import SocialMediaIcons from './SocialMediaIcons';

const SignUpForm = (props) => {

    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [message, setMessage] = useState(null);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const response = await fetch('http://localhost:3000/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name, email, password })
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.error || 'Erro ao registrar');
            }

            setMessage('Usuário registrado com sucesso!');
            // Opcional: redirecionar para login, ou salvar token, etc.
        } catch (err) {
            setMessage(err.message);
        }
    };

    return (
        <>
            <form onSubmit={handleSubmit} className="sign-up-form">
                <h2 className="title mb-3">Registre-se</h2>
                <div className="input-field">
                    <i className="fas fa-user"></i>
                    <input 
                        className="input-field-element"
                        type="text"
                        placeholder={props.username_placeholder}
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                    />
                </div>
                <div className="input-field">
                    <i className="fas fa-envelope"></i>
                    <input 
                        className="input-field-element"
                        type="email"
                        placeholder={props.email_placeholder}
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                    />
                </div>
                <div className="input-field">
                    <i className="fas fa-lock"></i>
                    <input 
                        className="input-field-element"
                        type="password"
                        placeholder={props.password_placeholder}
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                    />
                </div>
                <input type="submit" className="btn btn-success btn-submit rounded-pill px-4 py-2 my-2"/>
                {message && <p className="message">{message}</p>}
                <p className="social-text">{props.text}</p>
                <SocialMediaIcons />
            </form>
        </>
    )
}

export default SignUpForm