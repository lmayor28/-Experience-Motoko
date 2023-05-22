    /*

    ------------------------- GUIA DEL PROYECTO -------------------------

     Propiedades funcionales:
      Permitir a un usuario crear un post que por el momento solo contenga texto.
      Permitir borrar un post.
      Permitir al creador (YO) borrar cualquier post y manejar las cosas como quiero.
      Permitir a admins administrar los post por uso inapropiado.
      Poder ordenar los post por orden de votos (Solo este tipo de ordenamiento por ahora).
      Realizar un login con las cuentas (Las cuentas del bootcamp ya estan cargadas).

     Propiedades NO funcionales:
         * Guardar mi principal en "fisico". 
         * Para dar de alta a los admins debo de tener permiso yo y los admins.
         * Los admins no me pueden sacar el estatus de owner.
         * Solo los usuarios creadores(sin mencionar a los admins o owner) del post pueden modificar o borrar su post.
         * Los admins o owner NO pueden modificar un post, esto es para que no haya casos de mal uso del admin y enculpar al usuario.
         * LOS VOTOS NO SE PUEDEN MODIFICAR NI POR ADMINS o OWNER.

     Desarrollo de software:
      Para guardar los datos se va a utilizar la estructura de TrieMap o HashMap.
      Para el ordenamiento de datos de los votos se va a utilizar la estrucutura de Heap.
         

     Paso para desarrollar:
        1. Realizar la estructura donde se guardan los datos de las cuentas. ///
        2. Realizar la estructura donde se guardan los datos de los posts. ///
        3. Implementar la funcionalidad para crear y borrar posts. ///
        4. Implementar la funcionalidad para que el creador y los admins puedan administrar los posts. ///
        4.1 Implementar funcion que permita a owner dar admins. ///
        5. Implementar la funcionalidad para ordenar los posts por número de votos utilizando un heap. ///
        6. Implementar el sistema de login con las cuentas ya cargadas. ///
        8. Implementar el PostUpgrade y el PreUpgrade.
        7. Asegurarse de cumplir con las propiedades no funcionales especificadas.

     Pasos adicionales por olvidados:
        1. Realizar los tipos de las estruturas que guarden la siguiente informacion:
          * Account:
              |-- PrincipalID : Principal
              |-- userPosts : [Nat]
              |-- isAdmin : Bool
              |-- isOwner : Bool
              |-- isActive : Bool
              |-- userName : Text

          * Post:
              |--postId : Nat
              |--owner : account
              |--content : Text
              |--votes : Int
              |--createDate : Time
        
        2. Realizar las funciones voteUp y voteDown 

    
     Para revisar:
        1. Fijarse que funciones pueden pasarse a query.
        2. Guardar bien los datos para el upgrade.
        3. Poder cargar mi id sin problema.

     Pendiente: 
        Terminar funcion de agregar usuario. ///
        Terminar funcion de ordenar Heap. ///

        Ordenar los HeapPost cuando se actualizan.
        
    */
import Int "mo:base/Int";
import TrieMap "mo:base/TrieMap";
import Types "types";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Bool "mo:base/Bool";
import Order "mo:base/Order";
import Heap "mo:base/Heap";
import Option "mo:base/Option";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";

actor {

// -------------------------- Types --------------------------
    public type Post = Types.Post;
    public type User = Types.User;
    public type HeapPost = Types.HeapPost;

    let luisOwnerPrincipal : Principal = Principal.fromText("vnsis-y7wsc-5nalz-y3jxp-kkonp-4fkam-rygcc-ueztc-rnizd-j4cju-nae");
    

    stable var counterPostID: Nat = 0;
    let user0 : User = {
        principalID = luisOwnerPrincipal;  
        posts = [];
        userName = "Sin Conectar";
        status = #Other;
        isActive = false;
    };

    let post0 : Post = { 
        postID = 0;
        owner = user0;
        content = "";
        votes = 0;
        createDate = 0;
        voters = [];
    };
    // Canister del MBC
    var MBCprincipals : actor {
        getAllStudentsPrincipal : shared () -> async [Principal];
        getAllStudents: shared () -> async Result.Result<[Text], Text>;
    } = actor("rww3b-zqaaa-aaaam-abioa-cai");


// -------------------------- User Storage --------------------------
    // let studentProfileStore : HashMap.HashMap<Principal, StudentProfile> = HashMap.fromIter<Principal, StudentProfile>(datosGuardados.vals(), 0, Principal.equal, Principal.hash);

    stable var USER_ENTRIES : [(Principal, User)] = [];
    let userStorage : HashMap.HashMap<Principal, User> = HashMap.fromIter<Principal, User>(USER_ENTRIES.vals(),0, Principal.equal, Principal.hash);

// -------------------------- HeapPost Storage --------------------------
    func _heapPostCompare(x : HeapPost, y : HeapPost) : Order.Order {
        Int.compare(x.votes, y.votes);
    };

    stable var HEAPPOST_ENTRIES : Heap.Tree<HeapPost> = Heap.Heap<HeapPost>(_heapPostCompare).share();

    let heapStore : Heap.Heap<HeapPost> = Heap.Heap<HeapPost>(_heapPostCompare);
    heapStore.unsafeUnshare(HEAPPOST_ENTRIES);
    // let heap = Heap.Heap<Text>(Text.compare);

// -------------------------- Post Storage --------------------------
    // Funcion para crear un hash de un texto
    func _NatToHash (x : Nat) : Hash.Hash{
        Text.hash(Nat.toText(x));
    };

    stable var POST_ENTRIES : [(Nat, Post)] = [];

    let postStorage : TrieMap.TrieMap<Nat, Post> = TrieMap.fromEntries<Nat, Post>(POST_ENTRIES.vals(), Nat.equal, _NatToHash);

//  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text>
// -------------------------- Functions --------------------------

    // -------------------------- Create New Post --------------------------
        public func  createPost (contenido : Text, user : User) : async Result.Result<(), Text>{
            
            
            if (Principal.isAnonymous(user.principalID)){
                return #err("Usuarios anonimos no estan permitidos");
            };

            switch (userStorage.get(user.principalID)){
                case (null) { #err("No ha encontrado el usuario"); };
                case (?userOk){
                    if (not userOk.isActive){
                        return #err("El usuario no esta activo !!");
                    };
                    let newPost : Post = {
                        postID = counterPostID;
                        owner = userOk;
                        content = contenido;
                        votes = 0;
                        createDate = Time.now();
                        voters = [];
                    };

                    let postBuffer : Buffer.Buffer<Nat> = Buffer.fromArray(userOk.posts);
                    postBuffer.add(counterPostID);

                    let updatedUser : User = {
                        principalID = userOk.principalID;
                        posts = Buffer.toArray(postBuffer);
                        userName = userOk.userName;
                        status = userOk.status;
                        isActive = userOk.isActive;
                    };

                    // ignore Array.append<Nat>(userOk.posts, [counterPostID]);
                    // Array.append<Nat>(array1, array2)
                    userStorage.put(user.principalID, updatedUser);

                    _crearHeapPost(newPost);
                    postStorage.put(counterPostID, newPost);
                    counterPostID += 1;
                    #ok();
                };
            };
        };

        public query func seePosts() : async [Post]{
            let newHeapPost : Heap.Heap<HeapPost> = _cloneHeap(heapStore);
            let newBuffer = Buffer.Buffer<Post>(0);

            var heap : ?HeapPost = newHeapPost.removeMin();
            while (heap != null){

                let heapOk : HeapPost = Option.get(heap, {postId = 0; votes = 0;});
                let post : ?Post = postStorage.get(heapOk.postId);
                
                newBuffer.add(Option.get( post , post0 ));
                heap := newHeapPost.removeMin();

            };

            Buffer.toArray<Post>(newBuffer)
        };


    // -------------------------- Create New User --------------------------

        public query func  seeUsers() : async [(Text, Principal)]{

            let buffer : Buffer.Buffer<(Text, Principal)> = Buffer.Buffer<(Text, Principal)>(0);
            for (i in userStorage.vals()){
            buffer.add(i.userName, i.principalID);
            };

            Buffer.toArray(buffer);
        };

        public func _createNewUser(principal : Principal, _userName : Text) : async Bool{
            switch (userStorage.get(principal)){
                case (null){
                    var newUser : User = {
                        principalID = principal;
                        posts = [];
                        userName = _userName;
                        status = #User;
                        isActive = true;
                    };

                    if (principal == luisOwnerPrincipal){
                        newUser := {
                        principalID = principal;
                        posts = [];
                        userName = _userName;
                        status = #Owner;
                        isActive = true;
                        }
                    };

                    userStorage.put(principal, newUser);
                    true;
                };
                case (?yaExiste){
                    false;
                };
            }
        };

        // Para modificiar en el futuro para que pueda ingresar variso usuarios.
        public shared ({ caller }) func  createUser (principal : Principal, username : Text ) : async Result.Result<(), Text>{
            // if (Principal.isAnonymous(caller)){
            //     return #err("Usuarios anonimos no estan permitidos");
            // };


            // switch (userStorage.get(caller)){
            //     case (null){
            //         if (not (caller == luisOwnerPrincipal)){
            //             return #err("No estas registrado");
            //         };
            //         if(not _createNewUser(principal, username)){
            //             return #err("El usuario a registrar ya esta creado")
            //         };
            //         #ok();
            //     };
            //     case (?userOk){
            //         #ok();
            //     }
            // }

            ignore _createNewUser(principal, username);

            #ok();

        };

    // -------------------------- Delete Post --------------------------
        
        // -------------------------- Is Admin Function --------------------------
        func _IsAdminOrOwner(user : User) : Bool {
            ((user.status == #Admin) or (user.status == #Owner));
        };
        // -------------------------- Delete Main Function --------------------------
        public func deletePost (postID : Nat, user : User) : async Result.Result<(), Text>{
            if (Principal.isAnonymous(user.principalID)){
                return #err("Usuarios anonimos no estan permitidos");
            };

            switch (userStorage.get(user.principalID)){
                case (null) #err("No se ha encontrado el usuario.");
                case (?userOk){
                    switch(postStorage.get(postID)) {
                        case(null) { #err("No se ha encontrado el post") };
                        case(?postOk) {
                            if (not(postOk.owner.principalID == userOk.principalID) and not(_IsAdminOrOwner(userOk)) ){
                                return #err("No eres el dueño de este post");
                            };
                            _deleteAPostFromHeapPosts(postOk);
                            postStorage.delete(postID);
                            #ok();
                        };
                    };
                };
            };
        };

    // -------------------------- GetPost --------------------------
        func _getPost(id : Nat) : Post{
            switch (postStorage.get(id)){
                case (null) { post0 };
                case (?postOk){
                    postOk;
                };
            };
        };
    // -------------------------- GetUser --------------------------
        public query func getUser(principal : Principal) : async User {
            switch (userStorage.get(principal)){
              case (null){ user0 };
              case (?userOk){
                userOk;
              };
            };
        };

        public query func getMyUser( principal : Text) : async User {
            switch (userStorage.get(Principal.fromText(principal))){
                case (null) { user0; };
                case (?userOk) { userOk };
            };
        };
    // -------------------------- Add an Admin --------------------------
        public shared ({ caller }) func addAdmin (principal : Principal) : async Result.Result<(), Text> {
            if (Principal.isAnonymous(caller)){
                return #err("Usuarios anonimos no estan permitidos");
            };

            switch ( userStorage.get(caller) ){
                case (null) #err("No tiene un usuario creado");
                case (?callerOk){
                    switch ( userStorage.get(principal)){
                        case (null) #err("No existe el usuario que quiere dar el status de Admin");
                        case (?userOk){
                            if (not(callerOk.status == #Owner) ){
                                return #err("No eres el dueño !!");
                            };

                            let updatedUser : User = {
                                principalID = userOk.principalID;
                                posts = userOk.posts;
                                userName = userOk.userName;
                                status = #Admin;
                                isActive = userOk.isActive;
                            };
                            
                            ignore userStorage.replace(principal, updatedUser);
                            #ok();
                        };
                    };
                };
            };
        };
    // -------------------------- Ordenar Heap Por cantidad de votos --------------------------
        // Ver cierta cantidad de post
        public query func verXcantidadDePosts (cantPostFinal : Nat, cantidadPostIniciales : Nat) : async [Post]{
            // var cantidadPostIniciales : Nat = Option.get(cantPostInit, 0);
            var cantidadTotal : Nat = cantidadPostIniciales + cantPostFinal;

            let newHeapPost : Heap.Heap<HeapPost> = _cloneHeap(heapStore);
            let newBufferPost : Buffer.Buffer<Post> = Buffer.Buffer(0);

            var iterador : Nat = 0;

            var continueFlag : Bool = true;
            while (iterador <= cantidadTotal and continueFlag){
                var actualPost : ?HeapPost = newHeapPost.removeMin();
                switch (actualPost){
                    case (null){ continueFlag := false; };
                    case (?actualPostOk){
                        if (iterador < cantidadPostIniciales){
                            
                            iterador += 1;
                        } else {

                            newBufferPost.add(_getPost(actualPostOk.postId));
                            iterador += 1;
                        }
                    }
                }
            };

            Buffer.toArray(newBufferPost);         
        };
        
        // Crear un nuevo heap de post es una funcion privada 
        func _crearHeapPost(post : Post) : (){
            let newHeap : HeapPost = {
                postId = post.postID;
                votes = post.votes;
            };
            heapStore.put(newHeap);
        };

        // No estoy tan seguro que funcione :D
        func _deleteAPostFromHeapPosts(post : Post) : (){
            var newSnapshot : Heap.Tree<HeapPost> = heapStore.share();
            let newHeapPosts : Heap.Heap<HeapPost> = Heap.Heap<HeapPost>(_heapPostCompare);
            // newHeapPosts.unsafeUnshare(newSnapshot);
            
            var heapPost : ?HeapPost = heapStore.removeMin();
            while (not (heapPost == null)){
                switch (heapPost){
                    case (null){};
                    case (?heapPostOk){
                        if (heapPostOk.postId == post.postID){
                            
                            heapPost := heapStore.removeMin();
                        } else {
                            if (heapPostOk.postId != 0){
                                heapPost := heapStore.removeMin();
                                newHeapPosts.put(heapPostOk);
                            }
                        };
                    };
                }
            };

            newSnapshot := newHeapPosts.share();
            heapStore.unsafeUnshare(newSnapshot);
        };

        func _cloneHeap (heap : Heap.Heap<HeapPost>) : Heap.Heap<HeapPost> {
            var newSnapshot : Heap.Tree<HeapPost> = heap.share();
            let newHeapPosts : Heap.Heap<HeapPost> = Heap.Heap<HeapPost>(_heapPostCompare);

            newHeapPosts.unsafeUnshare(newSnapshot);

            return newHeapPosts;
        };

        public query func  getPostIdSortByVotes() : async [Nat] {
            let copyHeapPosts : Heap.Heap<HeapPost> = _cloneHeap(heapStore);
            let heapBuffer : Buffer.Buffer<Nat> = Buffer.Buffer<Nat>(0);
            var heapPost : ?HeapPost = copyHeapPosts.removeMin(); 
            
            while (not (heapPost == null)){
                var heapPostOk : HeapPost = Option.get<HeapPost>(heapPost, {postId = 0; votes = 0;} );
                heapBuffer.add(heapPostOk.postId);

                heapPost := copyHeapPosts.removeMin(); 
            };

            return Buffer.toArray<Nat>(heapBuffer);
        };
    // -------------------------- Cargar cuentas de MBC --------------------------
        // Queda en buscar a todos los alumnos y crear la cuenta a aquellos que no tengan cuenta
        public shared ({ caller }) func cargarCuentasMBC () : async Result.Result<(), Text> {
            switch(userStorage.get(caller)) {
                case(null) { 
                    if(caller == luisOwnerPrincipal){
                        ignore _createNewUser(caller, "lmayor28");
                        return #ok();
                    };
                    #err("No estas registrado")  };
                case(?userCallerOk){
                    if (not (userCallerOk.status == #Owner)){
                        return #err("No tienes el status para poder realizar esa accion");
                    };
                    try {
                        let allStudentsPrincipal : [Principal] = await MBCprincipals.getAllStudentsPrincipal();
                        var allStudentsUserName : [Text] = [];
                        switch (await MBCprincipals.getAllStudents()){
                          case (#err(textoError)){};
                          case (#ok(userNames)){
                            allStudentsUserName := userNames;

                          };
                        };

                        var contador : Nat = 0;
                        for (i in allStudentsPrincipal.vals()){
                            ignore _createNewUser(i, allStudentsUserName[contador]);
                            contador += 1;
                        };

                        // for ((principal, username) in (allStudentsPrincipal.vals(), allStudentsUserName.vals())){
                        //     ignore _createNewUser(principal);
                        // };
                        
                        #ok();
                    } catch e {
                        #err("Hubo un error al llamar al canister de MBC!!!");
                    }
                };
            };
        };

    // -------------------------- Cargar cuentas de MBC --------------------------
    public func voteUp(postID : Nat, user : User) : async Result.Result<(), Text> {
        switch(postStorage.get(postID)){
            case (null){ #err("No se ha encontrado el post")};
            case (?postOk){
                if ((Array.find<Principal>(postOk.voters, func x = x == user.principalID)) != null){
                    return #err("Ya has votado")
                };

                let newPost : Post = {
                    postID = postOk.postID;
                    owner = postOk.owner;
                    content = postOk.content;
                    votes = postOk.votes + 1;
                    createDate = postOk.createDate;
                    voters = Array.append<Principal>(postOk.voters, [user.principalID]);
                };
                
                postStorage.put(postID, newPost);
                #ok()
            };
        }
    };

    public func voteDown(postID : Nat, user : User) : async Result.Result<(), Text> {
        switch(postStorage.get(postID)){
            case (null){ #err("No se ha encontrado el post")};
            case (?postOk){
                if ((Array.find<Principal>(postOk.voters, func x = x == user.principalID)) != null){
                    return #err("Ya has votado")
                };

                let newPost : Post = {
                    postID = postOk.postID;
                    owner = postOk.owner;
                    content = postOk.content;
                    votes = postOk.votes - 1;
                    createDate = postOk.createDate;
                    // voters = Array.append<Principal>(postOk.voters, [user.principalID]);
                    voters = Array.append<Principal>(postOk.voters, [user.principalID]);
                };
                
                postStorage.put(postID, newPost);
                #ok()
            };
        }
    };

    public query func cantPosts() : async Nat {
        postStorage.size();
    };

    public query func cantUser() : async Nat {
        userStorage.size();
    };

    public func resetHeap() : (){
        let heapStore = Heap.Heap<HeapPost>(_heapPostCompare);
        for (i in postStorage.vals()){
            _crearHeapPost(i);
        };
    };








// -----------------------------------------------------------------------
    
    system func preupgrade (){

        USER_ENTRIES := Iter.toArray(userStorage.entries());
        POST_ENTRIES := Iter.toArray(postStorage.entries());
        HEAPPOST_ENTRIES := heapStore.share();
    };

    system func postupgrade () {
        USER_ENTRIES := [];
        POST_ENTRIES := [];
        heapStore.unsafeUnshare(HEAPPOST_ENTRIES);
        HEAPPOST_ENTRIES := Heap.Heap<HeapPost>(_heapPostCompare).share();
    };

    
};
