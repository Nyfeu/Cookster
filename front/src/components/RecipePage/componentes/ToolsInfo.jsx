import React from 'react'
import '../RecipePage.css'
import SingleUtensil from './SingleUtensil'

const ToolsInfo = ({utensils}) => {
    return (
        <div>
            <h4>Utensílios</h4>
            <ul className="tool-list">

                    {utensils.map((utensil, index) => (
                          <SingleUtensil
                            key={index}      
                            utensil={utensil}  
                          />
                        ))}
            </ul>
        </div>
    )
}

export default ToolsInfo