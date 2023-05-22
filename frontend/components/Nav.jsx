import React, { useEffect, useState } from "react"
import logotipo from "./../assets/IconM.png"


import { ConnectButton } from "@connect2ic/react"
import { Perfil } from "./Perfil"

const Nav = ({ User }) => {

    return (
        <div className="Nav color auth-section ">
            <div className="Logotipo">
                <a href="https://internetcomputer.org/docs/current/motoko/main/motoko" target="_blank">
                    <img className="LogoAni" src={logotipo} alt="Logotipo" />
                </a>
            </div>
            <div className="Buscar">
                {/* Buscar */}
            </div>
            <div className="Perfil moverIzquierda">
                <Perfil User={User} />
            </div>
            <div className="ConnectButton moverIzquierda">
                <ConnectButton />
            </div>
        </div>
    )
}

export { Nav }