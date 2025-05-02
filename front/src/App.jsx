import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AuthForm from "./components/AuthForm/AuthForm"
import LandingPage from "./components/LandingPage/LandingPage"
import './theme.css'
import RecipePage from './components/RecipePage/RecipePage';

function App() {

  return (
    <Router>
      <Routes>
        <Route path="/" element={<LandingPage/>}/>
        <Route path="/login" element={<AuthForm />} />
        <Route path="/recipe" element={<RecipePage />} />
      </Routes>
    </Router>
  )

}

export default App
