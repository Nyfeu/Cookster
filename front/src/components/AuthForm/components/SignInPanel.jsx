import React from 'react'

const SignInPanel = (props) => {
    return (
        <div className="panel left-panel">
            <div className="content">
                <h3>{props.title}</h3>
                <p>{props.text}</p>
                <button onClick={props.sign_up} className="btn btn-outline-light rounded-pill px-4 py-2" id="sign-up-btn">
                    Registre-se
                </button>
            </div>
            <img src="log.png" className="image log-img" alt="" />
        </div>
    )
}

export default SignInPanel