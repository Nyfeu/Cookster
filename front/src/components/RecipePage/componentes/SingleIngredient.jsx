import React from 'react'

const SingleIngredient = ({ ingredient }) => {
    return (
        <li><p className="single-ingredient ">
            {ingredient.quantity} {ingredient.unit} de {ingredient.name}
            {ingredient.note && ` (${ingredient.note})`}
        </p></li>
    )
}

export default SingleIngredient