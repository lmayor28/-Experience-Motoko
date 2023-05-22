export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Status = IDL.Variant({
    'User' : IDL.Null,
    'Admin' : IDL.Null,
    'Other' : IDL.Null,
    'Owner' : IDL.Null,
  });
  const User = IDL.Record({
    'status' : Status,
    'userName' : IDL.Text,
    'isActive' : IDL.Bool,
    'posts' : IDL.Vec(IDL.Nat),
    'principalID' : IDL.Principal,
  });
  const User__1 = IDL.Record({
    'status' : Status,
    'userName' : IDL.Text,
    'isActive' : IDL.Bool,
    'posts' : IDL.Vec(IDL.Nat),
    'principalID' : IDL.Principal,
  });
  const Time = IDL.Int;
  const Post = IDL.Record({
    'content' : IDL.Text,
    'owner' : User__1,
    'votes' : IDL.Int,
    'createDate' : Time,
    'voters' : IDL.Vec(IDL.Principal),
    'postID' : IDL.Nat,
  });
  return IDL.Service({
    '_createNewUser' : IDL.Func([IDL.Principal, IDL.Text], [IDL.Bool], []),
    'addAdmin' : IDL.Func([IDL.Principal], [Result], []),
    'cantPosts' : IDL.Func([], [IDL.Nat], ['query']),
    'cantUser' : IDL.Func([], [IDL.Nat], ['query']),
    'cargarCuentasMBC' : IDL.Func([], [Result], []),
    'createPost' : IDL.Func([IDL.Text, User], [Result], []),
    'createUser' : IDL.Func([IDL.Principal, IDL.Text], [Result], []),
    'deletePost' : IDL.Func([IDL.Nat, User], [Result], []),
    'getMyUser' : IDL.Func([IDL.Text], [User], ['query']),
    'getPostIdSortByVotes' : IDL.Func([], [IDL.Vec(IDL.Nat)], ['query']),
    'getUser' : IDL.Func([IDL.Principal], [User], ['query']),
    'resetHeap' : IDL.Func([], [], ['oneway']),
    'seePosts' : IDL.Func([], [IDL.Vec(Post)], ['query']),
    'seeUsers' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Text, IDL.Principal))],
        ['query'],
      ),
    'verXcantidadDePosts' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(Post)],
        ['query'],
      ),
    'voteDown' : IDL.Func([IDL.Nat, User], [Result], []),
    'voteUp' : IDL.Func([IDL.Nat, User], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };
