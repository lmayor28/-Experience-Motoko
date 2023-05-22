import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Time "mo:base/Time";
module {

    public type Time = Time.Time;
    public type Status = {
        #User;
        #Admin;
        #Owner;
        #Other;
    };

    public type User = {
      principalID : Principal;  
      posts : [Nat];
      userName : Text;
      status : Status;
      isActive : Bool;
    };

    public type Post = {
        postID : Nat;
        owner : User;
        content : Text;
        votes : Int;
        createDate : Time;
        voters : [Principal];
    }; 

    public type HeapPost = {
        postId : Nat;
        votes : Int;
    }

};