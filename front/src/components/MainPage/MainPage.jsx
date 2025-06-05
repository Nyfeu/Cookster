import React from "react";
import NavBar_Auth from "../NavBar_Auth";
import HeroSection from "./components/HeroSection";
import DespensaSection from "./components/DespensaSection";
import FeedSection from "./components/FeedSection";
import FooterSection from "./components/FooterSection";
import SidePanel from "./components/SidePanel";
import "./MainPage.css";

export default function MainPage() {
  return (
    <>
      <div className="container-page">

        <NavBar_Auth />
        <div className="container-fluid container-home p-0 d-flex flex-column">

          <HeroSection />
          <DespensaSection />
          <FeedSection />
          <SidePanel />
          <FooterSection />

        </div>
        

      </div>

    </>
  );
}