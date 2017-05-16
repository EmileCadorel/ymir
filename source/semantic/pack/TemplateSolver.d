module semantic.pack.TemplateSolver;
import ast.all;
import std.container, std.stdio;
import semantic.types.InfoType;
import utils.exception;
import utils.Singleton;
import std.conv;

/**
 Une solution de résolution template
 */
struct TemplateSolution {
    /// La solution est valide
    bool valid;

    /// Le type de la solution 
    InfoType type;

    /// Les types template inféré
    Expression [string] elements;    
}

alias TemplateSolver = TemplateSolverS.instance;

/**
 Classe singleton qui va permettre de résoudre les paramètres templates
 */
class TemplateSolverS {


    /**
     Fusionne deux instances de solutions de templates
     Params:
     left = les types inféré en premier
     right = les nouveau types a inséré
     Returns: les solutions sont complémentaire ?
     */
    bool merge (ref Expression [string] left, Expression [string] right) {
	foreach (key, value ; right) {
	    if (auto inside = key in left) {
		auto ltype = cast (Type) *inside;
		auto rtype = cast (Type) value;
		if (!ltype || !rtype || !ltype.info.type.isSame (rtype.info.type))
		    return false;		
	    } else {
		left [key] = value;
	    }
	}
	
	return true;
    }    
    
    /**
     Résolution du type d'un paramètre, 
     Example:
     -----------
     def foo (T of [U], U) (a : T) {
     }
     foo ([2, 3]); // solve ([T, U], a, [int]);
     -----------
     Params:
     tmps = la liste des paramètre templates de l'élément
     param = un paramètre dont il font résoudre le type
     type = le type du paramètre passé 
     Returns: le tableau associatif des nouvelles expression
     */
    TemplateSolution solve (Array!Expression tmps, Var param, InfoType type) {
	if (auto typed = cast (TypedVar) param) {
	    if (typed.expType) {
		return solve (tmps, typed.expType, type);
	    } else if (auto arr = cast (ArrayVar) typed.type) {
		return solve (tmps, arr, type);
	    } else {
		Array!InfoType types;
		auto soluce = TemplateSolution (true);
		foreach (it ; 0 .. typed.type.templates.length) {
		    if (auto var = cast (Var) typed.type.templates [it]) {
			if (!type.getTemplate (it)) return TemplateSolution (false);
			auto res = this.solveInside (tmps, var, type.getTemplate (it));
			if (!res.valid || !merge (soluce.elements, res.elements))
			    return TemplateSolution (false);
			types.insertBack (res.type);
		    }
		}
		
		foreach (it ; tmps) {
		    if (auto var = cast (Var) it) {
			if (typed.type.token.str == var.token.str) {
			    TemplateSolution res;
			    if (auto of = cast (OfVar) var)
				res = solve (tmps, of, typed, type);
			    else 
				res = solve (var, typed, type);
			    if (!res.valid || !merge (soluce.elements, res.elements))
				return TemplateSolution (false);
			    else {
				soluce.type = res.type;
				return soluce;
			    }
			}
		    } 
		}	    
		soluce.type = InfoType.factory (typed.type.token, types);
		return soluce;
	    }
	}
	return TemplateSolution (true);
    }

    /**
     Résolution du type d'un paramètre, 
     Params:
     tmps = la liste des paramètre templates de l'élément
     param = un paramètre dont il font résoudre le type
     type = le type du paramètre passé 
     Returns: le tableau associatif des nouvelles expression
     */
    TemplateSolution solveInside (Array!Expression tmps, Var param, InfoType type) {
	if (auto arr = cast (ArrayVar) param) {
	    return solve (tmps, arr, type);
	} else {
	    
	    Array!InfoType types;
	    auto soluce = TemplateSolution (true);
	    foreach (it ; 0 .. param.templates.length) {
		if (auto var = cast (Var) param.templates [it]) {
		    if (!type.getTemplate (it)) return TemplateSolution (false);
		    auto res = this.solveInside (tmps, var, type.getTemplate (it));
		    if (!res.valid || !merge (soluce.elements, res.elements))
			return TemplateSolution (false);
		    types.insertBack (res.type);
		}
	    }
	    
	    foreach (it ; tmps) {
		if (auto var = cast (Var) it) {
		    if (param.token.str == var.token.str) {
			TemplateSolution res;
			if (auto of = cast (OfVar) it)
			    res = solve (tmps, of, param, type);
			else
			    res = solve (var, param, type);
			if (!res.valid || !merge (soluce.elements, res.elements))
			    return TemplateSolution (false);
			else {
			    soluce.type = res.type;
			    return soluce;
			}
		    }
		} 
	    }	
	    soluce.type = InfoType.factory (param.token, types);
	    return soluce;
	}
    }
    

    /**
     Résoud un paramètre template de type tableau
     Example:
     --------
     def foo (T) (a : [T]) {
     }

     foo ([10]); // solve ([T], [T], [int]);

     --------
     Params:
     tmps = les paramètres templates de la fonction
     param = l'expression type de l'attribut
     type = Le type du paramètre
     Return: une solution template
     */
    private TemplateSolution solve (Array!Expression tmps, ArrayVar param, InfoType type) {
	import semantic.types.ArrayInfo;
	
	if (!cast (ArrayInfo) type) return TemplateSolution (false);
	auto content = param.content;
	auto type_ = type.getTemplate (0);
	if (type_ is null) return TemplateSolution (false);
	TemplateSolution res = this.solveInside (tmps, content, type_);
	if (res.valid)
	    return TemplateSolution (true, type.cloneForParam, res.elements);
	return TemplateSolution (false);
    }


    /**
     Résoud un paramètre template de type fonction
     Example:
     -------
     def foo (T) (a : function (T) : T) {         
     }

     foo ((a : int) => 10); // solve ([T], function (T) : T, funcPtr(int):int);
     -------
     */
    private TemplateSolution solve (Array!Expression tmps, Expression param, InfoType type) {
	import semantic.types.PtrFuncInfo;
	
	auto func = cast (PtrFuncInfo) type;
	auto ptr = cast (FuncPtr) param;
	if (!func || !ptr) return TemplateSolution (false);

	Array!InfoType types;       
	auto soluce = TemplateSolution (true);
	foreach (it ; 0 .. ptr.params.length) {
	    auto res = solveInside (tmps, ptr.params [it], func.getTemplate (it));
	    if (!res.valid || !merge (soluce.elements, res.elements))
		return TemplateSolution (false);
	    types.insertBack (res.type);
	}
	
	auto res = this.solveInside (tmps, ptr.type, func.getTemplate (ptr.params.length + 1));
	if (!res.valid || !merge (soluce.elements, res.elements))
	    return TemplateSolution (false);

	auto aux = new PtrFuncInfo ();
	aux.params = types;
	aux.ret = res.type;

	if (!func.CompOp (aux)) return TemplateSolution (false);	
	soluce.type = type.cloneForParam;
	return soluce;
    }            
    
    /**
     Résoud un paramètre template
     Params;
     elem = le paramètre templates
     param = le paramètre passé à la fonction
     type = le type du paramètre passé 
     Returns: le tableau associatif des nouvelles expressions
     */
    private TemplateSolution solve (Var elem, Var param, InfoType type) {
	if (auto tv = cast (TypedVar) elem) return TemplateSolution (false);
	else if (auto arr = cast (ArrayVar) elem) return TemplateSolution (false);
		
	auto type_ = type.cloneForParam;
	return TemplateSolution (true, type_, [elem.token.str : new Type (param.token, type_)]);
    }
    
    /**
     Résoud un paramètre template
     Params;
     elem = le paramètre templates
     param = le paramètre passé à la fonction
     type = le type du paramètre passé 
     Returns: le tableau associatif des nouvelles expressions
     */
    private TemplateSolution solve (Var elem, TypedVar param, InfoType type) {
	if (auto tv = cast (TypedVar) elem) return TemplateSolution (false);
	else if (auto arr = cast (ArrayVar) elem) return TemplateSolution (false);

	auto type_ = type.cloneForParam;
	return TemplateSolution (true, type_, [elem.token.str : new Type (param.type.token, type_)]);
    }


    /**
     Résoud un paramètre templates de type of
     Example:
     -------
     def foo (A of int) (a : A) {
     }
     foo (10); // solve (A of int, a : A, int);
     -------
     Params:
     elem = le paramètre template
     param = l'attribut de la fonction
     type = le type du paramètre passé à la fonction
     Returns: une solution template
     */
    private TemplateSolution solve (Array!Expression tmps, OfVar elem, Var param, InfoType type) {
	Var typeVar;
	if (auto t = cast (TypedVar) param) typeVar = t.type;
	else typeVar = param;
	
	auto res = this.solveInside (tmps, elem.type, type);
	if (!res.valid || !res.type.isSame (type)) return TemplateSolution (false);
	else {
	    auto soluce = res;
	    if (!merge
		(res.elements,
		 [elem.token.str : new Type (typeVar.token, type.cloneForParam)]
		)
	    )
		return TemplateSolution (false);
	    return res;
	}
    }    
    
    /**
     résolution des paramètre templates.
     Example:
     --------
     def foo (T of [U], U) () {
     }
     
     foo!([int]) (); // solve ([T, U], [[int]]);
     --------
     Params:
     tmps = la liste des paramètre templates de l'élément
     params = la liste des paramètre de opTemp
     Returns: le tableau associatif des nouvelles expressions
     */    
    TemplateSolution solve (Array!Expression tmps, Array!Expression params) {
	auto soluce = TemplateSolution (true);
	if (tmps.length < params.length) return TemplateSolution (false);
	foreach (it ; 0 .. params.length) {
	    TemplateSolution res;
	    if (auto v = cast (Var) tmps [it]) {
		res = this.solveInside (tmps, v, params [it]);
	    } else {
		res = this.solveInside (tmps, tmps [it] , params [it]); 
	    }
	    
	    if (!res.valid || !merge (soluce.elements, res.elements))
		return TemplateSolution (false);	    
	}
	
	return soluce;
    }

    
    /**
     Résoud un paramètre template
     Example:
     ------
     def foo (T) () {}
     foo!(int) ();

     def foo (a : string) () {
     }
     foo!"salut" ();
     ------

     Params:
     tmps = les paramètre templates de l'élément
     left = le paramètre template courant
     right = le paramètre template passé à la fonction
     Returns: une solution de résolution template
     */
    private TemplateSolution solveInside (Array!Expression tmps, Var left, Expression right) {
	if (auto typed = cast (TypedVar) left) {
	    return this.solveInside (tmps, typed, right);
	} else if (auto of = cast (OfVar) left) {
	    return this.solveInside (tmps, of, right);
	} else if (auto type = cast (Type) right) {
	    return this.solveInside (left, type);
	} else return TemplateSolution (false);
    }

    /**
     Résoud un paramètre template
     Example:
     -------     
     def foo (T) () {}
     foo!int (); //solveInside (T, int);
     -------
     */
    private TemplateSolution solveInside (Var left, Type right) {
	auto type = right.info.type;
	auto clo = right.clone ();
	clo.info.type = clo.info.type.cloneForParam ();
	return TemplateSolution (true, type, [left.token.str : clo]);
    }    

    /**
     Résoud un paramètre template
     Example:
     --------
     def foo (T of int) () {
     }
     foo!int (); //solveInside (T of int, int);
     --------
     */
    private TemplateSolution solveInside (Array!Expression tmps, OfVar left, Expression right) {
	auto type = cast (Type) right;
	if (!type) return TemplateSolution (false);

	auto res = this.solveInside (tmps, left.type, type.info.type);
	if (!res.valid || !res.type.isSame (type.info.type)) return TemplateSolution (false);
	else {
	    auto clo = type.clone ();
	    clo.info.type = clo.info.type.cloneForParam ();
	    auto soluce = res;
	    if (!merge
		(res.elements,
		 [left.token.str : clo]
		)
	    )
		return TemplateSolution (false);
	    return res;
	}
    }
    
    /**
     Résoud un paramètre template
     Example:
     -------     
     def foo (a : string) () {
     }
     foo!"salut" ();     
     -------
     */
    private TemplateSolution solveInside (Array!Expression tmps, TypedVar left, Expression right) {
	auto type = right.info.type;
	if (!right.info.isImmutable) throw new NotImmutable (right.info);
	
	auto res = this.solveInside (tmps, left.type, type);
	if (!res.valid) return TemplateSolution (false);

	if (!type.isSame (res.type)) return TemplateSolution (false);
	
	if (!merge (res.elements, [left.token.str : right.clone ()]))
	    return TemplateSolution (false);
	return res;
    }

    /**
     Résoud un paramètre template
     Example:
     --------
     def foo ("salut") () {
     }

     foo!("salut") ();
     --------
     */
    private TemplateSolution solveInside (Array!Expression tmps, Expression left, Expression right) {
	import semantic.types.StringInfo, semantic.types.CharInfo;
	import semantic.types.BoolInfo;

	auto elem = left.expression ();
	if (!right.info.isImmutable) throw new NotImmutable (right.info);
	InfoType res;
	
	if (cast (CharInfo) right.info.type && cast (StringInfo) elem.info.type) {
	    res = new BoolInfo ();
	    res.value = new BoolValue ((cast (CharValue) right.info.type.value).value == (cast (StringValue) elem.info.type.value).value [0]);
	} else if (cast (CharInfo) elem.info.type && cast (StringInfo) right.info.type) {
	    res = new BoolInfo ();
	    res.value = new BoolValue ((cast (CharValue) elem.info.type.value).value == (cast (StringValue) right.info.type.value).value [0]);
	} else {	    
	    auto op = Word.eof;
	    op.str = Tokens.DEQUAL.descr;			    
	    res = elem.info.type.BinaryOp (op, right.info.type);
	    if (!res || !res.value) return TemplateSolution (false);
	}
	
	auto b = cast (BoolValue) res.value;
	if (!b || !b.isTrue) 
	    return TemplateSolution (false);

	auto it = 0;
	foreach (et ; tmps) {
	    if (left is et) break;
	    else it++;
	}

	return TemplateSolution (true, elem.info.type, [it.to!string : right.clone()]);	
    }    
    
    /**
     Résolution des paramètre templates.
     Example:
     --------
     struct (T of [U], U) 
     | a : T
     -> Test;
     
     let a = Test!([int])(); // solve ([T, U], [[int]]);
     --------
     Params:
     tmps = la liste des paramètre templates de l'élément
     params = la liste des paramètre de opTemp
     Returns: le tableau associatif des nouvelles expressions
     */    
    TemplateSolution solve (Array!Var tmps, Array!Expression params) {
	Array!Expression aux;
	foreach (it ; tmps) {
	    aux.insertBack (it);
	}
	return solve (aux, params);
    }
      
    
    /**
     Vérifie que les paramètres templates sont valide
     Params:
     args = les paramètre templates
     */
    bool isValid (Array!Expression args) {
	foreach (it ; args) {
	    if (auto var = cast (Var) it) {
		foreach (it_ ; args) {
		    auto var_ = cast (Var) it_;
		    // Plusieurs paramètres avec le même nom
		    if (it !is it_ && var_ && var.token.str == var_.token.str)
			return false;
		}
	    }
	}
	return true;
    }
    
    /**
     Params:
     args = les paramètres templates de l'élément 
     soluce = la résolution
     Returns: Les paramètres templates ont été correctement typé, et le résultat est une solution valide ?
     */
    bool isSolved (Array!Expression args, TemplateSolution soluce) {
	if (!soluce.valid) return false;
	auto types = soluce.elements;
	foreach (it ; args) {
	    if (auto type = cast (TypedVar) it) {
		if (auto info = type.token.str in types) {
		    if (*info is null) return false;
		} else return false;
	    } else {
		if (auto info = it.token.str in types) {
		    if (*info is null) return false;
		} else return false;
	    }
	}
	return true;
    }

    /**
     Params:
     args = les paramètres templates de l'élément 
     types = la résolution
     Returns: Les paramètres templates ont été correctement typé, et le résultat est une solution valide ?
     */
    bool isSolved (Array!Expression args, Expression [string] types) {
	foreach (it ; args) {
	    if (auto type = cast (TypedVar) it) {
		if (auto info = type.token.str in types) {
		    if (*info is null) return false;
		} else return false;
	    } else {
		if (auto info = it.token.str in types) {
		    if (*info is null) return false;
		} else return false;
	    }
	}
	return true;
    }

    /**
     Example:
     -------
     def foo (A, B) () {
     }
     foo!int; // unSolved () == [B]
     -------
     Params:
     args = une liste de paramètre template
     soluce = une solution de résolution templates
     Returns: la liste des paramètre qui n'apparaissent pas résolue dans la solution
     */
    Array!Expression unSolved (Array!Expression args, TemplateSolution soluce) {
	import std.algorithm;
	Array!Expression rets;
	ulong nb = 0;
	foreach (it ; args) {
	    if (auto v = cast (Var) it) {
		if (!(v.token.str in soluce.elements))
		    rets.insertBack (it.templateExpReplace (soluce.elements));
	    } else {
		if (!(nb.to!string in soluce.elements))
		    rets.insertBack (it.templateExpReplace (soluce.elements));
	    }
	    nb ++;
	}

	return rets;
    }


    mixin Singleton;   
}