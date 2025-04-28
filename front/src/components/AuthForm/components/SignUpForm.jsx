import React from 'react'
import SocialMediaIcons from './SocialMediaIcons';

const SignUpForm = (props) => {
    return (
        <>
            <form action="#" className="sign-up-form">
                <h2 className="title mb-3">Registre-se</h2>
                <div className="input-field">
                    <i className="fas fa-user"></i>
                    <input type="text" placeholder={props.username_placeholder}/>
                </div>
                <div className="input-field">
                    <i className="fas fa-envelope"></i>
                    <input type="email" placeholder={props.email_placeholder}/>
                </div>
                <div className="input-field">
                    <i className="fas fa-lock"></i>
                    <input type="password" placeholder={props.password_placeholder} />
                </div>
                <input type="submit" className="btn btn-success btn-submit rounded-pill px-4 py-2 my-2"/>
                <p className="social-text">{props.text}</p>
                <SocialMediaIcons />
            </form>
        </>
    )
}

export default SignUpForm