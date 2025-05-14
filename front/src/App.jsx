import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AuthForm from "./components/AuthForm/AuthForm"
import LandingPage from "./components/LandingPage/LandingPage"
import MainPage from "./components/MainPage/MainPage"
import './theme.css'

function App() {

  return (
    <Router>
      <Routes>
        <Route path="/mainpage" element={<MainPage />}/>
        <Route path="/login" element={<AuthForm />} />
        <Route path="/landingpage" element={<LandingPage />} />
      </Routes>
    </Router>
  )

}

export default App
