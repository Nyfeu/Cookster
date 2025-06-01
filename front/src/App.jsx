import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Navigate } from 'react-router-dom';
import AuthForm from "./components/AuthForm/AuthForm"
import LandingPage from "./components/LandingPage/LandingPage"
import AuthSuccess from "./components/AuthForm/components/AuthSuccess"
import MainPage from "./components/MainPage/MainPage"

import './theme.css'

function App() {

  function ProtectedRoute({ children }) {
    console.log(localStorage.getItem('token'))
  return localStorage.getItem('token')?  <Navigate to="/mainpage" /> : children;
}

  return (
    <Router>
      <Routes>
        <Route path="/" element={<ProtectedRoute><LandingPage /></ProtectedRoute>} />
        <Route path="/login" element={<AuthForm sign_in_mode='sign_in'/>} />
        <Route path="/register" element={<AuthForm sign_in_mode='sign_up'/>} />
        <Route path="/auth-success" element={<AuthSuccess />} />
        <Route path="/mainpage" element={<MainPage />}/>
      </Routes>
    </Router>
  )

}

export default App
