import React, { Component } from 'react';
import './PageProfile.css'; // Caminho do CSS
import PainelReceitas from './components/PainelReceitas';
import PainelInfos from './components/PainelInfos';
import NavBar from '../NavBar';

class PageProfile extends Component {

    state = {
        username : "Anna Smith",
        bio : "UX/UI Designer",
        email : "anna@example.com",
        seguidores: 4073,
        seguindo: 322,
        posts: 200,
        descricao: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam erat volutpat. Morbi imperdiet, mauris ac auctor dictum, nisl ligula egestas nulla."
    }

    render() {
        return (
            <div className="header__wrapper">
                <header className='navbar'>
                    <div className="navbar__content">
                        <NavBar />
                    </div>
                </header>
                <div className="cols__container">
                    <PainelInfos 
                        username = {this.state.username}
                        bio = {this.state.bio}
                        email = {this.state.email}
                        seguidores = {this.state.seguidores}
                        seguindo = {this.state.seguindo}
                        posts = {this.state.posts}
                        descricao = {this.state.descricao}
                        />

                    <div className="right__col">
                    <div className="seguir">
                    <button>Seguir</button>
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
}

export default PageProfile;
