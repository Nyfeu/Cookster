import React, { Component } from 'react'
import './AuthForm.css'

export default class AuthForm extends Component {

    state = {
        sign_in: false,
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
                <div className={`container ${this.state.sign_in ? 'sign-up-mode' : ''}`}>
                    <div className="forms-container">
                        <div className="signin-signup">
                            <form action="#" className="sign-in-form">
                                <h2 className="title">Sign in</h2>
                                <div className="input-field">
                                    <i className="fas fa-user"></i>
                                    <input type="text" placeholder="Username" />
                                </div>
                                <div className="input-field">
                                    <i className="fas fa-lock"></i>
                                    <input type="password" placeholder="Password" />
                                </div>
                                <input type="submit" className="btn solid" />
                                <p className="social-text">Or Sign in with social platforms</p>
                                <div className="social-media">
                                    <a href="#" className="social-icon">
                                        <i className="fab fa-facebook-f"></i>
                                    </a>
                                    <a href="#" className="social-icon">
                                        <i className="fab fa-twitter"></i>
                                    </a>
                                    <a href="#" className="social-icon">
                                        <i className="fab fa-google"></i>
                                    </a>
                                    <a href="#" className="social-icon">
                                        <i className="fab fa-linkedin-in"></i>
                                    </a>
                                </div>
                            </form>
                            <form action="#" className="sign-up-form">
                                <h2 className="title">Sign up</h2>
                                <div className="input-field">
                                    <i className="fas fa-user"></i>
                                    <input type="text" placeholder="Username" />
                                </div>
                                <div className="input-field">
                                    <i className="fas fa-envelope"></i>
                                    <input type="email" placeholder="Email" />
                                </div>
                                <div className="input-field">
                                    <i className="fas fa-lock"></i>
                                    <input type="password" placeholder="Password" />
                                </div>
                                <input type="submit" className="btn" value="Sign up" />
                                <p className="social-text">Or Sign up with social platforms</p>
                                <div className="social-media">
                                    <a href="#" className="social-icon">
                                        <i className="fab fa-facebook-f"></i>
                                    </a>
                                    <a href="#" className="social-icon">
                                        <i className="fab fa-twitter"></i>
                                    </a>
                                    <a href="#" className="social-icon">
                                        <i className="fab fa-google"></i>
                                    </a>
                                    <a href="#" className="social-icon">
                                        <i className="fab fa-linkedin-in"></i>
                                    </a>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div className="panels-container">
                        <div className="panel left-panel">
                            <div className="content">
                                <h3>Novo por aqui?</h3>
                                <p>
                                    Se ainda não tem uma conta, crie uma agora mesmo e aproveite as
                                    vantagens de ser um membro da nossa comunidade.
                                    
                                </p>
                                <button onClick={this.sign_up} className="btn transparent" id="sign-up-btn">
                                    Sign up
                                </button>
                            </div>
                            <img src="log.svg" className="image log-img"  alt="" />
                        </div>
                        <div className="panel right-panel">
                            <div className="content">
                                <h3>Já é um de nós?</h3>
                                <p>
                                    Se já tem uma conta, faça login e desfrute das vantagens de ser um
                                    membro da nossa comunidade.
                                </p>
                                <button onClick={this.sign_in} className="btn transparent" id="sign-in-btn">
                                    Sign in
                                </button>
                            </div>
                            <img src="reg.svg" className="image reg-img" alt="" />
                        </div>
                    </div>
                </div>
                <script src="app.js"></script>
            </>
        )
    }
}
