import React, { useState, useEffect } from "react";
import { useCanister } from "@connect2ic/react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

import { faSync } from "@fortawesome/free-solid-svg-icons";

const Posts = ({user}) => {

    const [pagina, setPagina] = useState(1);
    const [postPorPagina, setPostPorPagina] = useState(15); 
    const [posts, setPosts] = useState(null);
    const [contador, setContador] = useState(0);

    const [cantPost, setCantPost] = useState(0);
    const [paginaMaximas, setPaginasMaximas] = useState(0);

    const [isOwner, setisOwner] = useState(false);
    
    const [backEnd] = useCanister("counter");


    const updateAllPost = async () => {
        setCantPost(await backEnd.cantPosts());
        
        var inicio = (pagina-1) * postPorPagina;
        var final = (pagina) * postPorPagina;

        const posts = await backEnd.verXcantidadDePosts(final, inicio)
        setPosts(posts);
        console.log(posts)
    }

    
    
    function formatDate(dateInNanoseconds){
        const dateInLilliseconds = dateInNanoseconds/ BigInt(1e6);
        const date = new Date(Number(dateInLilliseconds));
        return date.toLocaleDateString();
    };

    const seeUser = async () => {
        console.log("Principal: ", principal)
        console.log("User: ", user)
        console.log(await backEnd.seeUsers())
    }

    const setPaginasMax = () =>{
        var resu = Math.ceil(Number(cantPost) / Number(postPorPagina))
        setPaginasMaximas(Number(resu));
    }

    async function handleVoteUp (postID){
        if (user == null || user == undefined){
            return
        };
        await backEnd.voteUp(postID, user);
        updateAllPost();
    };

    async function handleVoteDown (postID){
        if (user == null || user == undefined){
            return
        };
        var resu = await backEnd.voteDown(postID, user);
        console.log(resu)
        updateAllPost();
        console.log("Se ha votado para abajo")
    };

    async function setPage (valor){
        var resu = await backEnd.cantPosts()
        setCantPost(resu);

        // if (cantPost < ((pagina) * postPorPagina)){
        //     return 
        // };
        
        setPagina(pagina + valor);
        console.log(pagina);
    };

    async function deletePost(postID){
        if (user == null || user == undefined){
            console.log("No registrado");
            return 
        }

        var resu = await backEnd.deletePost(postID, user);
        console.log(resu);
        updateAllPost()
    } ;

    function is_owner(post){
        if (user == null || user == undefined){
            return false;
        }
        setisOwner(user.principalID == post.postID)
    }

    useEffect(() => {
        updateAllPost()
        if (posts){
            setContador(contador + posts.length)
        }
        
        setPaginasMax()

    }, [pagina, postPorPagina, user])

    return (
        <div className="Post">
            <div className="Encabezado">
                <button className="demo-button" onClick={updateAllPost}>
                    <FontAwesomeIcon icon={faSync} />
                </button>
                

                <button className={`demo-button ${pagina == (paginaMaximas +1) ? 'disabled' : ''}`} onClick={() => {if (pagina !== paginaMaximas) setPage(1)}}>
                    Siguiente
                </button>

                <p>{pagina}</p>
                <button className={`demo-button ${pagina <= 1 ? 'disabled' : ''}`} onClick={() => {if (pagina > 1) setPage(-1)}}>
                    Anterior 
                </button>

                </div>
            <div className="ContenidoDeTodosLosPosts">
                {posts && posts.map(post => (
                    
                    <div className="Post" key={post.postID}>
                        <div className="CuerpoPrincipalPost">
                            <h2>{post.owner.userName}</h2>
                            
                            <p className="Post-Content">Contenido: {post.content}</p>
                            <div className="CuerpoPrincipal-Footer">
                                <p className="CreateDate">{formatDate(post.createDate)}</p>
                                <button  onClick={() => deletePost(post.postID)} className={`  demo-button DeletePost ${true ? '' : 'disabled'}` }>
                                    Borrar Post
                                </button>
                            </div>
                        </div>
                        <div className="Votes">
                            
                            <button onClick={() => handleVoteUp(post.postID)} className={`VoteButtom demo-button ${false ? 'disabled' : ''}`} >+</button>
                            <p className="CantVotes">Votes:</p>
                            <p className="CantVotes">{post.votes.toString()}</p>
                            <button onClick={() => handleVoteDown(post.postID)} className={`VoteButtom demo-button ${false ? 'disabled' : ''}`}>-</button>
                        </div>                    
                    </div>
                
                ))}

            </div>

            <div className="Posts-Footer">

            </div>
        </div>
    )
}

export {Posts}