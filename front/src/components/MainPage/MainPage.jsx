import React from "react";
import NavBar from "../NavBar";
import Hero from "./components/Hero";
import Despensa from "./components/Despensa";
import Feed from "./components/Feed";
import Footer from "./components/Footer";
import "./MainPage.css";

export default function MainPage() {
  return (
    <div className="container" style={{ paddingTop: '7vh' }}>
      <NavBar />
      <Hero />
      <Despensa />
      <Feed />
      <Footer />
    </div>
  );
}