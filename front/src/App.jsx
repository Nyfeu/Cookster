import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Navigate } from 'react-router-dom';
import AuthForm from "./components/AuthForm/AuthForm"
import LandingPage from "./components/LandingPage/LandingPage"
import AuthSuccess from "./components/AuthForm/components/AuthSuccess"
import MainPage from "./components/MainPage/MainPage"
import PageProfile from "./components/ProfilePage/PageProfile"

import './theme.css'
import RecipePage from './components/RecipePage/RecipePage';

function App() {

  function ProtectedRoute({ children }) {
    const token = localStorage.getItem('token');
    return token ? children : <Navigate to="/login" replace />;
  }

  function PublicRoute({ children }) {
    const token = localStorage.getItem('token');
    return token ? <Navigate to="/mainpage" replace /> : children;
  }

  return (
    <Router>
      <Routes>
        <Route path="/" element={<PublicRoute><LandingPage /></PublicRoute>} />
        <Route path="/mainpage" element={<ProtectedRoute><MainPage /></ProtectedRoute>} />
        <Route path="/profile" element={<ProtectedRoute><PageProfile /></ProtectedRoute>} />
        <Route path="/recipe" element={<ProtectedRoute><RecipePage /></ProtectedRoute>} />
        <Route path="/login" element={<PublicRoute><AuthForm sign_in_mode="sign_in" /></PublicRoute>} />
        <Route path="/register" element={<PublicRoute><AuthForm sign_in_mode="sign_up" /></PublicRoute>} />

        <Route path="/auth-success" element={<AuthSuccess />} />
      </Routes>
    </Router>
  )

}

export default App
