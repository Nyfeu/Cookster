import React from 'react'
import { Image } from 'primereact/image';

const PainelInfos = (props) => {
    return (
        <div className="left__col">
            <div className="img__container">
                <Image
                    src={`../${props.fotoPerfil}`}
                    zoomSrc={`../${props.fotoPerfil}`}
                    alt="Image"
                    width="120"
                    height="120"
                    preview
                    className="custom-avatar"
                />

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
            </div>
        </div>

    )
}

export default PainelInfos