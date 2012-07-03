open Prelude
open Ljs_syntax




(* If you change these, make sure to change the 
 * definitions of operators that is given to z3 *)
type jsType = 
  | TNull
  | TUndef
  | TString (* used only for concrete strings *)
  | TSymString (* used only for symbolic values *)
  | TBool
  | TNum
  | TObjPtr
  | TFun of int (* arity *)
  | TAny
  | TData
  | TAccessor

type typeEnv = (jsType * string) IdMap.t
exception TypeError of string

(* Used internally where we can have symbolic values or concrete values,
 * namely for attrs *)
type symbool = BTrue | BFalse | BSym of id
type symstring = SString of string | SSym of id

(* Used within GetField and SetField only *)
type field_type = SymField of id | ConField of id

(* Maps var ids to store locations *)
type env = (id * Store.loc) list
(* Represents the envs in the call stack of the evaluator *)
type env_stack = env list

type value =
  (* Scalar types *)
  | Null
  | Undefined
  | Num of float
  | String of string
  | True
  | False
  | Closure of id list * exp * env (* (args, body, env) *)
  (* ObjPtr is a pointer to an obj in the object store *)
  | ObjPtr of Store.loc
  (* NewSym is an uninitialized symbolic value,
   * which could either be a SymScalar or an ObjPtr *)
  | NewSym of id * Store.loc list (* TODO explain this list *)
  (* SymScalar is a symbolic value of a scalar type
   * (i.e. not a pointer or object) *)
  | SymScalar of id

and objlit =
  | ConObj of objfields
  (* Holds the locs of all objects in the store when it was created *)
  | SymObj of objfields * Store.loc list
  (* Placeholder for uninitialized sym objects *)
  | NewSymObj of Store.loc list
and objfields = { attrs: attrsv;
                  conps: propv IdMap.t; (* props with concrete field names *)
                  symps: propv IdMap.t; } (* props with symbolic field names *)
and
  attrsv = { code : Store.loc option; (* will be a Closure *)
             proto : Store.loc; (* ObjPtr, Null, or SymScalar asserted to be Null *)
             extensible : symbool;
             klass : symstring; (* string *)
             primval : Store.loc option; }
and (* Each prop has three attrs: value/accessor, enum, config *)
  propv =
  | Data of datav * symbool * symbool
  | Accessor of accessorv * symbool * symbool
(* Properties hold the location of their values in the value store.
 * Data props also have annother attr: writable *)
and datav = { value : Store.loc; writable : symbool; }
and accessorv = { getter : Store.loc; setter : Store.loc; }
   
and exval = 
  | Break of label * value
  | Throw of value
and label = string

and result = value * ctx
and exresult = exval * ctx

(* Obj store holds (obj, hide), where hide = true indicates
 * that the object is an LJS internal and therefore not a
 * possible assignment for a new sym value. *)
and ('v, 'o) sto =
  { vals : 'v Store.t;
    objs : 'o Store.t }
and sto_type = (value, objlit * bool) sto

and ctx = { constraints : sym_exp list;
            vars : typeEnv;
            store : sto_type;
            (* if true, new objs will be hidden in the store *)
            hide_objs : bool;
            print_env : env; }

(* language of constraints *)
and sym_exp =
  | Hint of string * Pos.t
  | Concrete of value 
  | STime of int
  | SLoc of Store.loc
  | SId of id
  | SOp1 of string * sym_exp
  | SOp2 of string * sym_exp * sym_exp
  | SApp of sym_exp * sym_exp list
  | SLet of id * sym_exp
  | SCastJS of jsType * sym_exp
  | SUncastJS of jsType * sym_exp
  | SAssert of sym_exp
  | SAnd of sym_exp list
  | SOr of sym_exp list
  | SNot of sym_exp
  | SImplies of sym_exp * sym_exp
  | SIsMissing of sym_exp
  | SGetField of id * id

(* Recursively applies f to all nested expressions in e,
 * then applies f to the result. So f can assume that all
 * sub-expressions have already had f applied to them.
 * Unfortunately, its not a *true* map because the exp type
 * isn't polymorphic. *)
let rec exp_map f e =
  let emf = exp_map f in
  let res = match e with
  | Hint _
  | Concrete _
  | STime _
  | SLoc _
  | SGetField _
  | SId _ -> e (* no nested exps *)
  | SOp1 (op, e) -> SOp1 (op, emf e)
  | SOp2 (op, e1, e2) -> SOp2 (op, emf e1, emf e2)
  | SApp (fu, args) -> SApp (fu, map emf args)
  | SLet (id, e) -> SLet (id, emf e)
  | SCastJS (t, e) -> SCastJS (t, emf e)
  | SUncastJS (t, e) -> SUncastJS (t, emf e)
  | SNot e -> SNot (emf e)
  | SAnd es -> SAnd (map emf es)
  | SOr es -> SOr (map emf es)
  | SImplies (pre, post) -> SImplies (emf pre, emf post)
  | SAssert e -> SAssert (emf e)
  | SIsMissing e -> SIsMissing (emf e)
  in f res

let is_equal a b = SApp (SId "=", [a; b])
let is_not_equal a b = SNot (is_equal a b)

(* TODO what are these? *)
let is_num t l = SApp(SId "isNum", [t; l])
let is_undef t l = SApp(SId "isUndef", [t; l])
let is_null t l = SApp(SId "isNull", [t; l])
let is_absent t l = SApp(SId "isAbsent", [t; l])
let is_bool t l = SApp(SId "isBool", [t; l])
let is_str t l = SApp(SId "isStr", [t; l])
let is_fun t l = SApp(SId "isFun", [t; l])
let is_objcell t l = SApp(SId "isObjCell", [t; l])
let is_obj t l = SApp(SId "isObj", [t; l])

let lookup_store t l = SApp(SId "lookup", [t; l])

let lookup_field o f = SApp(SId "lookupField", [o; f])
let add_dataField o f v w e c = SApp(SId "addField", [o; f; v; w; e; c])
let update_dataField o f v = SApp(SId "updateField", [o; f; v])
  

(* monad *)
let return v (pc : ctx) = ([(v,pc)], [])
let throw v (pc : ctx) = ([], [(v, pc)])
let also_return v pc (rets,exns) = ((v,pc)::rets,exns)
let also_throw v pc (rets,exns) = (rets,(v,pc)::exns)
let combine (r1,e1) (r2,e2) = (List.rev_append r1 r2, List.rev_append e1 e2)
let none = ([],[])

(* usually, the types are
   bind_both ((ret : result list), (exn : exresult list)) 
   (f : result -> (result list * exresult list))
   (g : exresult -> (result list * exresult list)) 
   : (result list * exresult list)
   but in fact the function is slightly more polymorphic than that *)
let bind_both (ret, exn) f g =
  let f_ret = List.map f ret in
  let g_exn = List.map g exn in
  List.fold_left (fun (rets,exns) (ret',exn') -> (List.rev_append ret' rets, List.rev_append exn' exns))
    (List.fold_left (fun (rets,exns) (ret',exn') -> (List.rev_append ret' rets, List.rev_append exn' exns))
       none f_ret)
    g_exn
let bind (ret,exn) f = bind_both (ret,exn) f (fun x -> ([], [x]))
let bind_exn (ret,exn) g = bind_both (ret,exn) (fun x -> ([x], [])) g

let collect cmp res_list = 
  map (fun grp -> (fst (List.hd grp), map snd grp))
    (group (fun (v1,_) (v2,_) -> cmp v1 v2) res_list)

(* Abstraction for environment *)

(* The "environment" is actually a stack of envs, representing
 * the call stack. The top env on the stack has the all of the
 * bindings currently in scope. *)
let mt_env = []
let mt_envs = [mt_env]

(* Functions that take advantage of the entire stack, which
 * are useful for the garbage collector and for closures. *)
let cur_env envs = List.hd envs
let f_cur_env f envs = (f (List.hd envs)) :: (List.tl envs)
let push_env env envs = env :: envs
(* Returns a list of all bindings in the env stack.
 * May contain duplicates. *)
let envs_bindings envs =
  fold_left
    (fun bindings env ->
       List.rev_append env bindings)
    [] envs

(* Functions that operate on an env stack as if it were
 * just the top env on the stack. This is useful when we 
 * only care about the current scope. *)
let env_lookup id envs = List.assoc id (cur_env envs)
let env_mem id envs = List.mem_assoc id (cur_env envs)
let env_add id loc envs =
  f_cur_env (fun env -> (id, loc) :: env) envs

(* Functions on one env *)
let env_fold f env acc = (* includes shadowed bindings *)
  List.fold_right 
    (fun (id, loc) acc -> f id loc acc)
    env acc


let mtPath = {
  constraints = [];
  vars = IdMap.empty;
  store = { objs = Store.empty; vals = Store.empty };
  hide_objs = true;
  print_env = mt_env; (* the env to use when printing results *)
}

let add_var id ty hint ctx = 
  { ctx with vars = IdMap.add id (ty, hint) ctx.vars }

let has_var id ctx = 
  IdMap.mem id ctx.vars

let fresh_var = 
  let count = ref 0 in
  (fun prefix t hint pc ->
    incr count;
    let nvar = "%%" ^ prefix ^ (string_of_int !count) in
    (nvar, (add_var nvar t hint pc)))

let const_string s pc = 
  let str = "S_" ^ s in
  if has_var str pc then (str, pc)
  else (str, (add_var str TString s pc))

let add_const_string s pc = snd (const_string s pc)

let field_str field ctx = 
  match field with
  | SymField f -> (f, add_var f TSymString f ctx)
  | ConField f -> const_string f ctx

let ty_to_string t = match t with
  | TNull -> "TNull"
  | TUndef -> "TUndef"
  | TString -> "TString"
  | TSymString -> "TSymString"
  | TBool -> "TBool"
  | TNum -> "TNum"
  | TObjPtr -> "TObjPtr"
  | TFun arity -> "TFun(" ^ (string_of_int arity) ^ ")"
  | TAny -> "TAny"
  | TData -> "TData"
  | TAccessor -> "TAccessor"

let check_type id t pc =
  try 
    let (found, hint) = IdMap.find id pc.vars in
    if t = TAny or found = t then pc
    else if found = TAny then
      { pc with vars = IdMap.add id (t, hint) pc.vars }
    else begin 
      Printf.printf "Known type of %s is %s, wanted %s\n" id (ty_to_string found) (ty_to_string t);
      raise (TypeError id)
    end
  with Not_found -> failwith ("[interp] unknown symbolic var" ^ id)

(* Produces a new context and a bool that is true if the new
 * context did not change (i.e. is the exact same context).
 * If the context didn't change, then we know it's constraints
 * are still satisfiable. *)
let add_constraint c ctx =
  (* Only add new constraints. *)
  if List.exists (fun c' -> c = c') ctx.constraints
  then (ctx, true)
  else ({ ctx with constraints = c :: ctx.constraints }, false)

let add_assert a = add_constraint (SAssert a)
let add_let a b ctx = fst (add_constraint (SLet (a, b)) ctx)
let add_hint s p ctx = fst (add_constraint (Hint (s, p)) ctx)


let sto_alloc_val v ctx = 
  let (loc, sto) = Store.alloc v ctx.store.vals in
   (*Printf.eprintf "allocing loc %s in vals\n" (Store.print_loc loc); *)
  (loc, { ctx with store = { ctx.store with vals = sto } })

let sto_alloc_obj o ctx = 
  let (loc, sto) = Store.alloc (o, ctx.hide_objs) ctx.store.objs in
   (*Printf.eprintf "allocing loc %s in objs\n" (Store.print_loc loc); *)
  (loc, { ctx with store = { ctx.store with objs = sto } })

let sto_update_val loc v ctx = 
  { ctx with store = { ctx.store with
    vals = Store.update loc v ctx.store.vals }}

let sto_update_obj loc ov ctx = 
  let (_, hide) = Store.lookup loc ctx.store.objs in
  { ctx with store = { ctx.store with
    objs = Store.update loc (ov, hide) ctx.store.objs }}

let sto_lookup_obj loc ctx = 
(*   Printf.eprintf "looking for %s in objs\n" (Store.print_loc loc); *)
  fst (Store.lookup loc ctx.store.objs)

let sto_lookup_obj_pair loc ctx = 
  Store.lookup loc ctx.store.objs

let sto_lookup_val loc ctx = 
(*   Printf.eprintf "looking for %s in vals\n" (Store.print_loc loc); *)
  Store.lookup loc ctx.store.vals

(* Returns the loc of a newly allocated SymScalar *)
let alloc_sym_scalar name hint_s pc =
  let (sym_id, pc) = fresh_var name TAny hint_s pc in
  let (sym_loc, pc) = sto_alloc_val (SymScalar sym_id) pc in
  (sym_loc, pc)

let alloc_sym_scalar_opt name hint_s pc =
  let (sym_loc, pc') = alloc_sym_scalar name hint_s pc in
  combine
    (return (Some sym_loc) pc')
    (return None pc)

(* Creates a new symbolic boolean to be used as an attr *)
let new_sym_bool name hint_s pc =
  let (sym_id, pc) = fresh_var name TBool hint_s pc in
  (BSym sym_id, pc)

(* Creates a new symbolic string to be used as an attr *)
let new_sym_string name hint_s pc =
  let (sym_id, pc) = fresh_var name TSymString hint_s pc in
  (SSym sym_id, pc)

(* Creates a NewSym given a list of locs. Should only be used alone when creating the
 * prototypes for symbolic objects (since a sym obj's proto uses the same list of locs).
 * All other new sym allocation should use new_sym *)
let new_sym_from_locs locs name hint pc = 
  let sym_id, pc = fresh_var name TAny hint pc in
  (* Create a new symbolic object placeholder, and add it to the store.
   * This will account for the possibility that the new sym is a
   * pointer to an unknown symbolic object. This obj will be init'd later 
   * using init_sym_obj below. *)
  let new_loc, pc = sto_alloc_obj (NewSymObj locs) pc in
  (* include the just-allocated location *)
  (NewSym (sym_id, new_loc::locs), pc)

(* Creates a new symbolic value. Does not allocate it in the store. *)
let new_sym hint pc = 
  (* Get locs of all non-hidden objects in the store so we can branch
   * once we know the type of this sym value *)
  let locs =
    Store.fold
      (fun loc (_, hide) locs ->
        if hide then locs else loc :: locs)
      pc.store.objs [] in
  new_sym_from_locs locs "" hint pc

(* A fresh sym is a new sym that isn't equal to any objects
 * already in the store. *)
(* TODO probably still want to allow its prototype to have locs *)
let new_sym_fresh hint pc =
  new_sym_from_locs [] "" hint pc

(* Creates a new sym obj whose attributes are all symbolic. Most are scalars, or scalar
 * opts, except for the prototype, which could be a scalar (hopefully Null) or an obj, so
 * we use a NewSym. The locs for this NewSym (i.e., the locs of every object it could be
 * equal to) should be the same as the locs for the sym obj we are init'ing, since the
 * proto would had to have exist before this obj. *)
let init_sym_obj locs loc hint_s pc =
  let sym_ext, pc = new_sym_bool "extensible" "extensible attr" pc in
  let sym_klass, pc = new_sym_string "klass" "klass attr" pc in
  let proto, pc = new_sym_from_locs locs "proto"
                          ("new %proto for " ^ (Store.print_loc loc)) pc in
  let proto_loc, pc = sto_alloc_val proto pc in
  (*bind (alloc_sym_scalar_opt "code" "code attr" pc) *)
  (*  (fun (code_loc_opt, pc) ->*)
  (*    bind (alloc_sym_scalar_opt "primval" "primval attr" pc)*)
  (*      (fun (pv_loc_opt, pc) ->*)
  let pv_loc, pc = alloc_sym_scalar "primval" "primval attr" pc in
  let ret = SymObj ({
    attrs = { code = None; proto = proto_loc; extensible = sym_ext;
              klass = sym_klass; primval = Some pv_loc };
    conps = IdMap.empty;
    symps = IdMap.empty
  }, locs) in
  return ret (sto_update_obj loc ret pc)
