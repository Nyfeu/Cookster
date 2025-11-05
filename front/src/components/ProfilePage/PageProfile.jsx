/* eslint-disable no-unused-vars */
import React, { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';
import './PageProfile.css';
import PainelReceitas from './components/PainelReceitas';
import PainelInfos from './components/PainelInfos';
import NavBar_Auth from '../NavBar_Auth';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faGear } from '@fortawesome/free-solid-svg-icons';
import { Link } from 'react-router-dom';
import { useParams } from 'react-router-dom';

const PageProfile = () => {
    const comparador = JSON.parse(localStorage.getItem('user')).id
    const userId = useParams().userId

    const [profile, setProfile] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);


    const [username, setUsername] = useState(null);
    const [bio, setBio] = useState("Carregando bio...");
    const [profissao, setProfissao] = useState("Carregando profissão...");
    const [email, setEmail] = useState(null);
    const [seguidores, setSeguidores] = useState(0);
    const [seguindo, setSeguindo] = useState(0);
    const [posts, setPosts] = useState(0);
    const [fotoPerfil, setFotoPerfil] = useState('');
    const [descricao, setDescricao] = useState(
        "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam erat volutpat. Morbi imperdiet, mauris ac auctor dictum, nisl ligula egestas nulla."
    );


    useEffect(() => {
        const fetchUserProfile = async () => {
            if (!userId) {
                setError("ID do usuário fixo não foi definido.");
                setLoading(false);
                return;
            }

            try {
                setLoading(true);
                setError(null);

                const token = localStorage.getItem("token");

                if (!token) {
                    console.error("Token não encontrado. Usuário pode não estar autenticado.");
                    return;
                }

                const response = await fetch(`http://localhost:2000/profile/${userId}`, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${token}`,
                    }
                });

                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.message || `Erro HTTP: ${response.status}`);
                }

                const responseData = await response.json();
                setProfile(responseData.data);
            } catch (err) {
                console.error("Erro ao buscar perfil:", err);
                setError(err.message || "Erro desconhecido ao buscar perfil.");
                setProfile(null);
            } finally {
                setLoading(false);
            }
        };

        fetchUserProfile();

    }, [userId]); 



    useEffect(() => {
        if (profile) {
            setBio(profile.bio);
            setProfissao(profile.profissao);
            setFotoPerfil(profile.fotoPerfil);
            setUsername(profile.name);
            setEmail(profile.email)
            setDescricao(profile.descricao)
        }
    }, [profile]); 




    if (loading) {
        return <p>Carregando perfil...</p>;
    }

    if (error) {
        return <p style={{ color: 'red' }}>Erro: {error}</p>;
    }

    if (!profile) {
        return <p>Nenhum perfil encontrado para este usuário.</p>;
    }

    console.log(profile)

    return (
        <div className="profile-page">

        <div className="header__wrapper">
            <NavBar_Auth />
            <div className='banner'></div>
            <div className="cols__container">
                <PainelInfos
                    username={username}
                    bio={bio}
                    profissao={profissao}
                    email={email}
                    seguidores={seguidores}
                    seguindo={seguindo}
                    posts={posts}
                    descricao={descricao}
                    fotoPerfil={fotoPerfil}
                />

                <div className="right__col">
                    <div className="seguir">
                        {(userId == comparador) ?
                        <Link to={`/settings/${userId}`}>
                            <FontAwesomeIcon icon={faGear} className="gear-icon" />
                        </Link>
                        :
                        <button>Seguir</button>
                        }
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
        </div>
    );
};

export default PageProfile;