import React from 'react'

const SingleInstruction = ({stepText, index}) => {
  return (
        <div className="single-instruction">
      <header>
        <p>Passo {index + 1}</p>
        <div></div>
      </header>
      <p>
        {stepText}
      </p>
    </div>
  )
}

export default SingleInstruction