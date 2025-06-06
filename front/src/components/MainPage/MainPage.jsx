import React, { useState } from "react";
import NavBar_Auth from "../NavBar_Auth";
import HeroSection from "./components/HeroSection";
import DespensaSection from "./components/DespensaSection";
import FeedSection from "./components/FeedSection";
import FooterSection from "./components/FooterSection";

import "./MainPage.css";

export default function MainPage() {

  const [refreshFeed, setRefreshFeed] = useState(false);

  const triggerFeedRefresh = () => {
    setRefreshFeed(prev => !prev);
  };


  return (
    <>
      <div className="container-page">

        <NavBar_Auth />

        <div className="container-fluid container-home p-0 d-flex flex-column">

          <HeroSection />
          <DespensaSection onPantryChange={triggerFeedRefresh} />
          <FeedSection key={refreshFeed} />
          <FooterSection />

        </div>
        
      </div>

    </>
  );
}