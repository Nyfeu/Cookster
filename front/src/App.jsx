import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AuthForm from "./components/AuthForm/AuthForm"
import LandingPage from "./components/LandingPage/LandingPage"
import './theme.css'
import PageProfile from './components/ProfilePage/PageProfile';

function App() {

  return (
    <Router>
      <Routes>
        <Route path="/" element={<LandingPage/>}/>
        <Route path="/login" element={<AuthForm />} />
        <Route path="/user" element={<PageProfile />} />
      </Routes>
    </Router>
  )

}

export default App
