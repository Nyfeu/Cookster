import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AuthForm from "./components/AuthForm/AuthForm"
import LandingPage from "./components/LandingPage/LandingPage"
import './theme.css'

function App() {

  return (
    <Router>
      <Routes>
        <Route path="/" element={<LandingPage/>}/>
        <Route path="/login" element={<AuthForm sign_in_mode='sign_in'/>} />
        <Route path="/register" element={<AuthForm sign_in_mode='sign_up'/>} />
      </Routes>
    </Router>
  )

}

export default App
