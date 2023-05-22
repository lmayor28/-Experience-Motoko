import React, { useState } from "react";
import { useCanister } from "@connect2ic/react";



const CreatePost = ( {user} ) => {

    const [content, setContent] = useState("");
    const [backEnd] = useCanister("counter")


    const handleSubmit = async event => {
        event.preventDefault();
        // Llama a la función de Motoko para subir los datos
        const resu = await backEnd.createPost(content, user)
        console.log(resu)

    };

    return (
        <form className="CreatePost" onSubmit={handleSubmit}>
            <label>
                Texto: 
                <input
                type="text"
                value={content}
                onChange={event => setContent(event.target.value)}
                />
            </label>
            <p>El value es: {content}</p>
            <button type="submit">Subir</button>
        </form>
    )
}

export {CreatePost}

