import React from 'react'
import SocialMediaIcons from './SocialMediaIcons';

const SignInForm = (props) => {
    return (
        <>
            <form action="#" className="sign-in-form">
                <h2 className="title">Acesse</h2>
                <div className="input-field">
                    <i className="fas fa-user"></i>
                    <input type="text" placeholder={props.username_placeholder}/>
                </div>
                <div className="input-field">
                    <i className="fas fa-lock"></i>
                    <input type="password" placeholder={props.password_placeholder}/>
                </div>
                <input type="submit" className="btn solid" />
                <p className="social-text">{props.text}</p>
                <SocialMediaIcons />
            </form>
        </>
    )
}

export default SignInForm