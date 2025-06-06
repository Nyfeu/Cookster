import React from 'react'
import '../RecipePage.css'
import SingleIngredient from './SingleIngredient'

const IngredientsInfo = ({ingredients, index}) => {
    return (
        <div>
            <h4>Ingredientes</h4>
            <ul className="ingredient-list ">
                {ingredients.map((ingredient, index) => (
                    <SingleIngredient
                    key = {index} 
                    ingredient={ingredient}/>
                ))}
            </ul>
        </div>
    )
}

export default IngredientsInfo