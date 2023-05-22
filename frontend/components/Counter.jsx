import { useCanister, useConnect } from "@connect2ic/react"
import React, { useEffect, useState } from "react"

const Counter = () => {
  /*
  * This how you use canisters throughout your app.
  */
  const [counter] = useCanister("counter")
  const [count, setCount] = useState()
  const estadoPrincipal = <p>Sin conectar</p>
  

  const refreshCounter = async () => {
    const freshCount = await counter.getValue()
    setCount(freshCount)
  }

  const increment = async () => {
    await counter.increment()
    await refreshCounter()
  }

  const resetCounter = async () => {
    await counter.resetCounter()
    await refreshCounter()
  }

  useEffect(() => {
    if (!counter) {
      return
    }
    refreshCounter()
  }, [counter])

  return (
    <div className="example">
        <p style={{ fontSize: "2.5em" }}>{count?.toString()}</p> 
      <button className="connect-button" onClick={increment}>+</button>
      <button className="connect-button" onClick={resetCounter}>Reset</button>
    </div>
  )
}

export { Counter }