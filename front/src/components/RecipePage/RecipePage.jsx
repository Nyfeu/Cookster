import React, { Component } from 'react'
import './RecipePage.css'
import NavBar from '../NavBar'

export default class RecipePage extends Component {
  render() {
    return (
        <div>
            <div className="nav">
            <NavBar />
            </div>

        {/* main content */}
        <main className="page">
          <div className="recipe-page">
            <section className="recipe-hero">
              <img
                src="./receitas-salsicha.jpg"
                className="img recipe-hero-img"
                alt="recipe"
              />
              <article className="recipe-info">
                <h2>Banana Pancakes</h2>
                <p>
                  Shabby chic humblebrag banh mi bushwick, banjo kale chips
                  meggings. Cred selfies sartorial, cloud bread disrupt blue bottle
                  seitan. Dreamcatcher tousled bitters, health goth vegan venmo
                  whatever street art lyft shabby chic pitchfork beard. Drinking
                  vinegar poke tbh, iPhone coloring book polaroid truffaut tousled
                  ramps pug trust fund letterpress. Portland four loko austin
                  chicharrones bitters single-origin coffee. Leggings letterpress
                  occupy pour-over.
                </p>
                <div className="recipe-icons">
                  <article>
                    <i className="fas fa-clock"></i>
                    <h5>prep time</h5>
                    <p>30 min.</p>
                  </article>
                  <article>
                    <i className="far fa-clock"></i>
                    <h5>cook time</h5>
                    <p>15 min.</p>
                  </article>
                  <article>
                    <i className="fas fa-user-friends"></i>
                    <h5>serving</h5>
                    <p>6 servings</p>
                  </article>
                </div>
                <p className="recipe-tags">
                  Tags : <a href="tag-template.html">beef</a>
                  <a href="tag-template.html">breakfast</a>
                  <a href="tag-template.html">pancakes</a>
                  <a href="tag-template.html">food</a>
                </p>
              </article>
            </section>
  
            {/* content */}
            <section className="recipe-content">
              <article>
                <h4>instructions</h4>
                {/* single instruction */}
                <div className="single-instruction">
                  <header>
                    <p>step 1</p>
                    <div></div>
                  </header>
                  <p>
                    I'm baby mustache man braid fingerstache small batch venmo
                    succulents shoreditch.
                  </p>
                </div>
  
                {/* single instruction */}
                <div className="single-instruction">
                  <header>
                    <p>step 2</p>
                    <div></div>
                  </header>
                  <p>
                    Pabst pitchfork you probably haven't heard of them, asymmetrical
                    seitan tousled succulents wolf banh mi man bun bespoke selfies
                    freegan ethical hexagon.
                  </p>
                </div>
  
                {/* single instruction */}
                <div className="single-instruction">
                  <header>
                    <p>step 3</p>
                    <div></div>
                  </header>
                  <p>
                    Polaroid iPhone bitters chambray. Cornhole swag kombucha
                    live-edge.
                  </p>
                </div>
              </article>
              <article className="second-column">
                <div>
                  <h4>ingredients</h4>
                  <p className="single-ingredient">1 1/2 cups dry pancake mix</p>
                  <p className="single-ingredient">1/2 cup flax seed meal</p>
                  <p className="single-ingredient">1 cup skim milk</p>
                </div>
                <div>
                  <h4>tools</h4>
                  <p className="single-tool">Hand Blender</p>
                  <p className="single-tool">Large Heavy Pot With Lid</p>
                  <p className="single-tool">Measuring Spoons</p>
                  <p className="single-tool">Measuring Cups</p>
                </div>
              </article>
            </section>
          </div>
        </main>
  
      </div>
    )
  }
}
