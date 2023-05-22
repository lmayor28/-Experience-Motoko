import React, { useState } from "react"

import logo from "./assets/dfinity.svg"

import { Principal } from '@dfinity/principal'

/*
* Connect2ic provides essential utilities for IC app development
*/
import { createClient } from "@connect2ic/core"
import { defaultProviders } from "@connect2ic/core/providers"
import { ConnectButton, ConnectDialog, Connect2ICProvider, useConnect, useCanister } from "@connect2ic/react"
import "@connect2ic/core/style.css"
/*
* Import canister definitions like this:
*/
import * as counter from "../.dfx/local/canisters/counter"
/*
* Some examples to get you started
*/
import { Counter } from "./components/Counter"
import { Transfer } from "./components/Transfer"
import { Profile } from "./components/Profile"
import { Nav } from "./components/Nav"
import { Posts } from "./components/Posts"
import { CreatePost } from "./components/CreatePost"

// import { backEnd } from "./../canisters/counter/main.mo"

// import { useConnect } from "@connect2ic/react"

function App() {
   
  const {
    principal,
    connect,
    disconnect,
    status,
    isInitializing,
    isIdle,
    isConnecting,
    isConnected,
    isDisconnecting,
    activeProvider,
  } = useConnect({
    onConnect: () => {
      // Obtengo la informacion del usuario y se guarda en el estado
      getUserInfo().then(userInfo => {
        setUser(userInfo)
      })
      
      console.log("On Connect: " + user)
      
      // console.log(user)
    },
    onDisconnect: () => {
      // Signed out
      console.log("On Disconnect: " + user)
      
      // setUser(null)
    }
  })
  
  const [backEnd] = useCanister("counter")
  const [user, setUser] = useState(null)

  const [showHeaderContent, setShowHeaderContent] = useState(true);
  
  const getUserInfo = async () => {
    // console.log(typeof(principal))
    console.log(principal)
    // const principalTrue = Principal.fromText(principal)
    if (principal == undefined) {
      return
    }
    const userInfo = await backEnd.getUser(principal)
    // console.log( userInfo.principalID )
    return userInfo
    
  }

  const intervalID = setInterval(() => {
    if (isConnected && user == null){
      // cargarUsuario()
    }
  }, 10000
  );

  const seeUser = async () => {
    console.log("Principal: ", principal)
    console.log("User: ", user)
    console.log(await backEnd.seeUsers())
  }

  const cargarUsuario = async () => {
    const usuario = await backEnd.getMyUser(principal)
    console.log(usuario)
    setUser(usuario)
  }

  const handleTimeUpdate = (event) => {
    const currentTime = event.target.currentTime;
    if (currentTime >= 13 && currentTime <= 15) {
      setShowHeaderContent(false);
    } else {
      setShowHeaderContent(true);
    }
  }


  
  return (
    <div className="App">
      

      <ConnectDialog />

      {/* Comienzo del header */}
      <Nav User={user}/>
      <header className="App-header">
        
        <div className="video-container">
          <video autoPlay muted loop id="myVideo">
            <source src="https://drive.google.com/uc?export=download&id=1GzAXMe3tsR0GTHhxhaEP7NrPVoKYmOhS" type="video/mp4"/>
          </video>
        </div>


      </header>
      
      <div className={`header-content${showHeaderContent ? '' : 'hidden'}`}>
        <p className="slogan Motoko" id="Motoko">MOTOKO BOOTCAMP</p>
        <p className="Introduccion">Esta es una aplicación web creada con Motoko que permite dejar comentarios de texto y votar los comentarios de otros usuarios. La aplicación tiene como objetivo recoger las opiniones y experiencias de los participantes en el bootcamp de Motoko. Se invita a los usuarios a dejar sus comentarios y a votar los comentarios que les parezcan más interesantes o útiles. La pagina se encuentra en desarrollo pero agradecen las sugerencias de nuevas funcionalidades o mejoras para la aplicación. Se espera que disfruten de la aplicación web y que compartan sus aprendizajes!!! <a href="https://github.com/lmayor28/-Experience-Motoko/">GitHub del proyecto</a>. <a href="https://twitter.com/LuisMayorMoren1">By @lmayor28</a></p>
        {/* <p className="slogan">{principal}</p> */}
        <p className="twitter">by <a href="https://twitter.com/LuisMayorMoren1">@LUISoseaYo</a></p>


      </div>
        {/* <img src={logo} className="App-logo" alt="logo" /> */}
      
      {/* <button className="connect-button" onClick={seeUser}>See User</button> */}
      <div className="center">
        <button className="center connect-button" onClick={cargarUsuario}>Cargar Cuenta</button>

      </div>
      

      <div className="CuerpoPrincipal">
        <div className="Posts">
          <Posts user={user} />
        </div>
        <div className="BarraLiteral">
          <CreatePost user={user} />
        </div>
      </div>

      <footer className="Footer">

      </footer>
    </div>
  )
}

const client = createClient({
  canisters: {
    counter,
  },
  providers: defaultProviders,
  globalProviderConfig: {
    /*
     * Disables dev mode in production
     * Should be enabled when using local canisters
     */
    dev: import.meta.env.DEV,
  },
})

export default () => (
  <Connect2ICProvider client={client}>
    <App />
  </Connect2ICProvider>
)
