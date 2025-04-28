import React, { Component } from 'react'
import './AuthForm.css'
import SignUpForm from './components/SignUpForm';
import SignInForm from './components/SignInForm';
import SignInPanel from './components/SignInPanel';
import SignUpPanel from './components/SignUpPanel';
import NavBar from '../NavBar';

export default class AuthForm extends Component {

    state = {
        sign_in: true,
    }

    constructor(props) {
        super(props);
    }

    sign_in = () => {
        this.setState({ sign_in: false });
        console.log("sign in clicked");
        console.log(this.state.sign_in);
    }

    sign_up = () => {
        this.setState({ sign_in: true });
        console.log("sign up clicked");
        console.log(this.state.sign_in);
    }

    render() {
        return (
            <>
                <div className={"d-flex flex-column"}>
                    <NavBar/>
                    <div className={`container-puro ${this.state.sign_in ? 'sign-up-mode' : ''}`}>
                        <div className="forms-container">
                            <div className="signin-signup">
                                <SignInForm
                                    username_placeholder="Nome de usuário"
                                    password_placeholder="Senha"
                                    text="Ou acesse com suas redes sociais"
                                />
                                <SignUpForm
                                    username_placeholder="Nome de usuário"
                                    password_placeholder="Senha"
                                    email_placeholder="Email"
                                    text="Ou registre-se com suas redes sociais"
                                />
                            </div>
                        </div>

                        <div className="panels-container">
                            <SignInPanel
                                title="Novo por aqui?"
                                text="Se ainda não tem uma conta, crie uma agora mesmo e aproveite as vantagens de ser um membro da nossa comunidade."
                                sign_up={this.sign_up}
                            />
                            <SignUpPanel
                                title="Já é um de nós?"
                                text="Se já tem uma conta, faça login e desfrute das vantagens de ser um membro da nossa comunidade."
                                sign_in={this.sign_in}
                            />
                        </div>
                    </div>
                </div>
            </>
        )
    }
}
