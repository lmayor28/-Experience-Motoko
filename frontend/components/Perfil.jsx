import React from "react";

const Perfil = ({ User }) => {
    // console.log(User)
    if ( User == null ){
        // console.log(User)
        return (
            <div className="SinInicioDeSesion">
                Sin sesion iniciada
            </div>
        )  
    } else {
        // console.log(User)
        return (
            <div className="Saludo">
                Hola, {User.userName}
                {/* {console.log(User)} */}
            </div>
        )
    }


}

export { Perfil }