import React from 'react'

const SignUpPanel = (props) => {
    return (
        <div className="panel right-panel">
            <div className="content">
                <h3>{props.title}</h3>
                <p>{props.text}</p>
                <button onClick={props.sign_in} className="btn transparent" id="sign-in-btn">
                    Acesse
                </button>
            </div>
            <img src="reg.svg" className="image reg-img" alt="" />
        </div>
    )
}

export default SignUpPanel