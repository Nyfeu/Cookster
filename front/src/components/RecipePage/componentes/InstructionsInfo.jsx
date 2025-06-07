/* eslint-disable no-unused-vars */
import React from 'react'
import '../RecipePage.css'
import SingleInstruction from './SingleInstruction'

const InstructionsInfo = ({steps, index}) => {

  return (
    <div className="instructions-list">
    {steps.map((step, index) => (
          <SingleInstruction
            key={index}      
            stepText={step}  
            index={index}    
          />
        ))}
    </div>

  )
}

export default InstructionsInfo