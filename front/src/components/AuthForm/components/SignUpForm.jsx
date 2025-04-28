import React from 'react'
import SocialMediaIcons from './SocialMediaIcons';

const SignUpForm = (props) => {
    return (
        <>
            <form action="#" className="sign-up-form">
                <h2 className="title">Registre-se</h2>
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
                <input type="submit" className="btn"/>
                <p className="social-text">{props.text}</p>
                <SocialMediaIcons />
            </form>
        </>
    )
}

export default SignUpForm