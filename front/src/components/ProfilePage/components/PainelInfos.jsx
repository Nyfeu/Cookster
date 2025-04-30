import React from 'react'

const PainelInfos = (props) => {
    return (
        <div className="left__col">
            <div className="img__container">
                <img src="user.jpeg" alt="Anna Smith" />

            </div>
            <h2>{props.username}</h2>
            <p>{props.bio}</p>
            <p>{props.email}</p>

            <ul className="about">
                <li><span>{props.seguidores}</span>Seguidores</li>
                <div></div>              
                <li><span>{props.seguindo}</span>Seguindo</li>
                <div className='p-2'></div>
                <li><span >{props.posts}</span>Posts</li>
            </ul>

            <div className="content">
                <p>
                    {props.descricao}
                </p>

                <ul>
                    <li><i className="fab fa-twitter social-icon"></i></li>
                    <li><i className="fab fa-pinterest social-icon"></i></li>
                    <li><i className="fab fa-facebook social-icon"></i></li>
                    <li><i className="fab fa-instagram social-icon"></i></li>

                </ul>
            </div>
        </div>

    )
}

export default PainelInfos