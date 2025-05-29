import React, { Component } from 'react';
import { useEffect, useState } from "react";
import { useLocation } from 'react-router-dom';
import './PageProfile.css';
import PainelReceitas from './components/PainelReceitas';
import PainelInfos from './components/PainelInfos';
import NavBar_Auth from '../NavBar_Auth';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faGear } from '@fortawesome/free-solid-svg-icons';
import { Link } from 'react-router-dom';


const PageProfile = (props) => {

      const location = useLocation();
    const token = location.state?.token;

    const [username, setUsername] = useState();

    const [bio, setBio] = useState("UX/UI Designer");
    const [email, setEmail] = useState(null);
    const [seguidores, setSeguidores] = useState(4073);
    const [seguindo, setSeguindo] = useState(322);
    const [posts, setPosts] = useState(200);
    const [descricao, setDescricao] = useState(
        "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam erat volutpat. Morbi imperdiet, mauris ac auctor dictum, nisl ligula egestas nulla."
    );
    

    const [error, setError] = useState(null)
    const [user, setUser] = useState()

    useEffect(() => {
        fetch('http://localhost:3000/register', {
            headers: {
                Authorization: `Bearer ${token}`
            }
        })
            .then(async res => {
                const data = await res.json()

                if (!res.ok) throw new Error(data.error)
                setUser(data[0])
            })
            .catch(err => {
                console.error('ERRO NO FETCH:', err.message)
                setError(err.message)
            })

    }, [])

    useEffect(() => {
        if (user) {
            setUsername(user.name)
            setEmail(user.email)
        }
    }, [user])

    if (error) return <div>{error}</div>
    if (!user) return (
        <div className="center-container"> 
            Carregando...
        </div>
    )

    console.log(token)
    

    return (
        <div className="header__wrapper">
            <NavBar_Auth/>
            <div className='banner'></div>
            <div className="cols__container">
                <PainelInfos
                    username={username}
                    bio={bio}
                    email={email}
                    seguidores={seguidores}
                    seguindo={seguindo}
                    posts={posts}
                    descricao={descricao}
                />

                <div className="right__col">
                    <div className="seguir">
                        <Link  to="/profile"
                                        >
                                            <FontAwesomeIcon icon={faGear} className="gear-icon" />
                                        </Link>
                        
                        <button>
                            {
                                (token) ?
                                    "Editar Perfil"
                                    :
                                    "Seguir"
                            }
                        </button>
                    </div>
                    <nav>
                        <ul>
                            <li><a href="#">Receitas</a></li>
                        </ul>
                    </nav>
                    <PainelReceitas />
                </div>
            </div>
        </div>
    );
}


export default PageProfile;
