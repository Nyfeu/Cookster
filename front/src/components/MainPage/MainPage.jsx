import React from "react";
import NavBar from "../NavBar";
import HeroSection from "./components/HeroSection";
import DespensaSection from "./components/DespensaSection";
import FeedSection from "./components/FeedSection";
import FooterSection from "./components/FooterSection";
import "./MainPage.css";

export default function MainPage() {
  return (
    <div className="container-page">
      
      <NavBar />
      <div className="container-fluid" style={{ padding: '80px 0 0 0' }}>
        
        <HeroSection />
        <DespensaSection />
        <FeedSection />
        <FooterSection />
      </div>
    </div>
  );
}