import React from 'react'
import './EditProfilePage.css'
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';

const EditProfilePage = () => {

    const navigate = useNavigate()
    const userId = useParams().userId
    console.log(userId)
    const [isInputDisabled, setIsInputDisabled] = useState(true)
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const [formData, setFormData] = useState({
        fotoPerfil: '',
        username: '',
        email: '',
        bio: '',
        descricao: ''
    });

    const getUserId = () => {
        return JSON.parse(localStorage.getItem('user')).id
    };


    useEffect(() => {
        const fetchProfileData = async () => {
            setLoading(true);
            setError(null);
            const userId_comp = getUserId(); 
            console.log(userId_comp)
            if (userId_comp != userId) {
                setError("Usuário não autenticado. Faça login para ver seu perfil.");
                setLoading(false);

                return;
            }
            console.log('oi')
            try {
                const response = await fetch(`http://localhost:5000/profile/${userId}`, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',

                    },

                });

                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.message || 'Falha ao carregar os dados do perfil.');
                }

                const profileData = await response.json();
                console.log(profileData.data)
                setFormData({
                    fotoPerfil: profileData.data.fotoPerfil || 'default-profile.jpeg',
                    bio: profileData.data.bio || '',
                    descricao: profileData.data.descricao || '',
                    email: profileData.data.email || '',
                    username: profileData.data.name || '',
                });
            } catch (err) {
                console.error("Erro ao carregar o perfil:", err);
                setError(`Erro ao carregar o perfil: ${err.message}`);
            } finally {
                setLoading(false);
            }
        };

        fetchProfileData();
    }, []); 

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prevState => {
            const newState = {
                ...prevState,
                [name]: value
            };
            return newState;
        });
    };

    const handleSaveChanges = async () => {
        setLoading(true); 
        setError(null);
        const userId_comp = getUserId() 

        if (userId_comp != userId) {
            setError("Usuário não autenticado. Por favor, faça login.");
            setLoading(false);
            return;
        }

        try {
            const response = await fetch(`http://localhost:5000/profile/${userId}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData),
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || 'Erro ao salvar as alterações do perfil.');
            }

            const result = await response.json();
            alert("Perfil atualizado com sucesso!");
            navigate(`/profile/${userId}`)

        } catch (err) {
            console.error("Erro ao salvar o perfil:", err);
            setError(`Falha ao atualizar o perfil: ${err.message}`);
            alert(`Falha ao atualizar o perfil: ${err.message}`);
        } finally {
            setLoading(false);
        }
    };

    const cancel = () => {
        navigate(`/profile/${userId}`);
    };

    if (loading) {
        return <div className="container light-style flex-grow-1 container-p-y">Carregando perfil...</div>;
    }

    if (error) {
        return <div className="container light-style flex-grow-1 container-p-y" style={{ color: 'red' }}>{error}</div>;
    }


    return (
        <div className="container light-style flex-grow-1 container-p-y">
            <h4 className="font-weight-bold py-3 mb-4">
                Account settings
            </h4>
            <div className="card overflow-hidden">
                <div className="row no-gutters row-bordered row-border-light">
                    <div className="col-md-12">
                        <div className="tab-content">
                            <div className="tab-pane fade active show" id="account-general">
                                <div className="card-body card-media">
                                    <img src="../default-profile.jpeg" alt="User Avatar"
                                        className="d-block ui-w-80" />
                                    <div className="media-body ml-4">
                                        <label className="btn btn-primary">
                                            Upload new photo
                                            <input type="file" className="account-settings-fileinput" />
                                        </label> &nbsp;
                                        <button type="button" className="btn btn-default md-btn-flat">Reset</button>
                                    </div>
                                </div>
                                <hr className="border-light m-0" />
                                <div className="card-body">
                                    <div className="form-group">
                                        <label className="form-label">Username:</label>
                                        <input
                                            type="text"
                                            className="form-control mb-1"
                                            name='Username'
                                            value={formData.username}
                                            onChange={handleChange}
                                            disabled={isInputDisabled}
                                            style={{ backgroundColor: isInputDisabled ? '#e0e0e0' : 'white' }} />
                                    </div>
                                    <div className="form-group">
                                        <label className="form-label">Bio:</label>
                                        <input
                                            type="text"
                                            className="form-control mb-1"
                                            name='bio'
                                            value={formData.bio}
                                            onChange={handleChange} />
                                    </div>
                                    <div className="form-group">
                                        <label className="form-label">E-mail:</label>
                                        <input
                                            type="text"
                                            className="form-control mb-1"
                                            name='email'
                                            value={formData.email}
                                            onChange={handleChange}
                                            disabled={isInputDisabled}
                                            style={{ backgroundColor: isInputDisabled ? '#e0e0e0' : 'white' }} />
                                    </div>
                                    <div className="form-group">
                                        <label className="form-label">Descricao:</label>
                                        <input
                                            type="text"
                                            className="form-control mb-1"
                                            name="descricao"
                                            value={formData.descricao}
                                            onChange={handleChange} />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div className="text-right mt-3">
                <button type="button" className="btn btn-primary" onClick={handleSaveChanges}>Salvar Alterações</button>&nbsp;
                <button type="button" className="btn btn-default" onClick={cancel}>Cancel</button>
            </div>
        </div>
    )
}

export default EditProfilePage