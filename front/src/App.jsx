import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AuthForm from "./components/AuthForm/AuthForm"
import LandingPage from "./components/LandingPage/LandingPage"
import AuthSuccess from "./components/AuthForm/components/AuthSuccess"
import MainPage from "./components/MainPage/MainPage"

import './theme.css'
import PageProfile from './components/ProfilePage/PageProfile';

function App() {

  return (
    <Router>
      <Routes>
        <Route path="/" element={<LandingPage/>}/>
        <Route path="/login" element={<AuthForm sign_in_mode='sign_in'/>} />
        <Route path="/register" element={<AuthForm sign_in_mode='sign_up'/>} />
        <Route path="/auth-success" element={<AuthSuccess />} />
        <Route path="/mainpage" element={<MainPage />}/>
        <Route path="/profile" element={<PageProfile />}/>
      </Routes>
    </Router>
  )

}

export default App
