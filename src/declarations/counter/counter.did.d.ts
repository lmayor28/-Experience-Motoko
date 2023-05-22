import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Post {
  'content' : string,
  'owner' : User__1,
  'votes' : bigint,
  'createDate' : Time,
  'voters' : Array<Principal>,
  'postID' : bigint,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Status = { 'User' : null } |
  { 'Admin' : null } |
  { 'Other' : null } |
  { 'Owner' : null };
export type Time = bigint;
export interface User {
  'status' : Status,
  'userName' : string,
  'isActive' : boolean,
  'posts' : Array<bigint>,
  'principalID' : Principal,
}
export interface User__1 {
  'status' : Status,
  'userName' : string,
  'isActive' : boolean,
  'posts' : Array<bigint>,
  'principalID' : Principal,
}
export interface _SERVICE {
  '_createNewUser' : ActorMethod<[Principal, string], boolean>,
  'addAdmin' : ActorMethod<[Principal], Result>,
  'cantPosts' : ActorMethod<[], bigint>,
  'cantUser' : ActorMethod<[], bigint>,
  'cargarCuentasMBC' : ActorMethod<[], Result>,
  'createPost' : ActorMethod<[string, User], Result>,
  'createUser' : ActorMethod<[Principal, string], Result>,
  'deletePost' : ActorMethod<[bigint, User], Result>,
  'getMyUser' : ActorMethod<[string], User>,
  'getPostIdSortByVotes' : ActorMethod<[], Array<bigint>>,
  'getUser' : ActorMethod<[Principal], User>,
  'resetHeap' : ActorMethod<[], undefined>,
  'seePosts' : ActorMethod<[], Array<Post>>,
  'seeUsers' : ActorMethod<[], Array<[string, Principal]>>,
  'verXcantidadDePosts' : ActorMethod<[bigint, bigint], Array<Post>>,
  'voteDown' : ActorMethod<[bigint, User], Result>,
  'voteUp' : ActorMethod<[bigint, User], Result>,
}
