module ymir.semantic.types.StructInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container, std.stdio;
import std.format;

/**
 Le constructeur de structure
*/
class StructCstInfo : InfoType {

    /** Le nom de la structure */
    private string _name;

    /** Le parametre de la structure */    
    private Array!TypedVar _params;

    /** Les types des parametres de la structure*/
    private Array!InfoType _types;

    /** Les templates découvert à la syntaxe */
    private Array!Expression _tmps;
    
    /** Les templates utilisé pour la spécilisation */
    private Array!InfoType _oldTmps;

    /++ Les méthodes implémenté par un impl +/
    private Array!MethodInfo _methods;
    
    private static StructInfo [string] __doings__;
    
    /** Le nom des parametres*/
    private Array!string _names;
    
    /** La structure a été importé ?*/
    private bool _extern;

    /** La structure peut être construire en dehors du block ? */
    private bool _isPublic;    
    
    /+++/
    private static StructCstInfo [string] __creations__;
    
    /++
     L'emplacemence de la création de la structure.
     +/
    private Namespace _namespace;
    
    this (Namespace space, string name, Array!Expression tmps) {
	super (true);
	this._namespace = space;
	this._name = name;
	this._tmps = tmps;
    }

    /**
     Returns: la structure vient d'un import ?
    */
    ref bool isExtern () {
	return this._extern;
    }

    ref bool isPublic () {
	return this._isPublic;
    }

    /++
     Returns: les méthodes implémentés par un impl.
     +/
    ref Array!MethodInfo methods () {
	return this._methods;
    }
    
    /** 
     Ajoute un attributs à la structure
     Params:
     type = l'attribut (doit avoir été analysé sémantiquement)
     */
    void addAttrib (TypedVar type) {
	this._params.insertBack (type);
    }
    
    bool needCreation () {
	return this._tmps.length == 0 && !this._extern;
    }
    
    /**
     Returns: le nom de la structure
     */
    string name () {
	return this._name;
    }

    Namespace namespace () {
	return this._namespace;
    }

    /**
     Instancie un objet crée a partir d'un patron de structure
     Params:
     name = le nom de la structure à créer
     templates = les paramètre templates passé au constructeur
     Throws: NotATemplate
     Returns: une instance de StructInfo
     */
    static InfoType create (Word name, Expression [] templates) {
	auto info = Table.instance.get (name.str).type;
	auto cst = cast(StructCstInfo) (info);
		
	if (cst is null) {
	    cst = (cast (ObjectCstInfo) info).impl;
	}
	if (cst._tmps.length == 0 && templates.length != 0)
	    throw new NotATemplate (name);

	if (cst._tmps.length != 0) {
	    auto ret = cst.TempOp (make!(Array!Expression) (templates));
	    if (ret is null) throw new NotATemplate (name, make!(Array!Expression) (templates));
	    return ret.emptyCall (name).ret;
	}

	auto mangledName = Mangler.mangle!"struct" (cst);	
	if (auto it = mangledName in __doings__) return *it;

	auto ret = cast (StructInfo) StructInfo.create (cst._namespace, cst._name, cst._names, cst._types, cst._oldTmps, cst.methods);
	__doings__ [mangledName] = ret;
	
	if (ret._params.empty) {	    	    
	    foreach (it ; cst._params) {
		auto printed = false;
		Symbol sym;
		if (auto fn = cast (FuncPtr) it.expType) {
		    auto type = fn.expression;
		    sym = type.info;
		} else if (auto array = cast (ArrayAlloc) it.expType) {
		    assert (false, "TODO");
		} else {
		    it.type.asType ();
		}
		if (sym) {
		    auto _st = cast (StructCstInfo) (sym.type);
		    if (_st) {
			ret._params.insertBack (_st);
			ret._attribs.insertBack (it.token.str);
			printed = true;			
		    }		    
		}
		if (!printed) {
		    ret._params.insertBack (it.getType ());
		    ret._attribs.insertBack (it.token.str);
		}		
	    }
	}

	ret.isExtern = cst._extern;
	return ret;
    }


    /**
     Instancie un objet crée a partir d'un patron de structure
     Params:
     name = le nom de la structure à créer
     templates = les paramètre templates passé au constructeur
     Throws: NotATemplate
     Returns: une instance de StructInfo
     */
    InfoType createStr (Word name, Expression [] templates) {
	if (this._tmps.length == 0 && templates.length != 0)
	    throw new NotATemplate (name);

	if (this._tmps.length != 0) {
	    auto ret = this.TempOp (make!(Array!Expression) (templates));
	    if (ret is null) throw new NotATemplate (name, make!(Array!Expression) (templates));
	    return ret.emptyCall (name).ret;
	}

	auto mangledName = Mangler.mangle!"struct" (this);	
	if (auto it = mangledName in __doings__) return *it;

	auto ret = cast (StructInfo) StructInfo.create (this._namespace, this._name, this._names, this._types, this._oldTmps, this.methods);
	__doings__ [mangledName] = ret;
	
	if (ret._params.empty) {	    	    
	    foreach (it ; this._params) {
		auto printed = false;
		Symbol sym;
		if (auto fn = cast (FuncPtr) it.expType) {
		    auto type = fn.expression;
		    sym = type.info;
		} else if (auto array = cast (ArrayAlloc) it.expType) {
		    assert (false, "TODO");
		} else {
		    it.type.asType ();
		}
		if (sym) {
		    auto _st = cast (StructCstInfo) (sym.type);
		    if (_st) {
			ret._params.insertBack (_st);
			ret._attribs.insertBack (it.token.str);
			printed = true;			
		    }		    
		}
		if (!printed) {
		    ret._params.insertBack (it.getType ());
		    ret._attribs.insertBack (it.token.str);
		}		
	    }
	}

	ret.isExtern = this._extern;
	return ret;
    }

    
    InfoType create (Word name) {
	auto mangledName = Mangler.mangle!"struct" (this);
	if (auto it = mangledName in __doings__) return *it;
	
	auto ret = cast (StructInfo) StructInfo.create (this._namespace, this._name, this._names, this._types, this._oldTmps, this._methods);
	__doings__ [mangledName] = ret;
	ret.isExtern = this._extern;
	
	if (ret._params.empty) {	    
	    foreach (it ; this._params) {
		auto printed = false;
		Symbol sym;
		if (auto fn = cast (FuncPtr) it.expType) {
		    auto type = fn.expression;
		    sym = type.info;
		} else if (auto array = cast (ArrayAlloc) it.expType) {
		    assert (false, "TODO");
		} else {
		    sym = it.type.asType ().info;
		}
		if (sym) {
		    auto _st = cast (StructCstInfo) (sym.type);		    
		    if (_st) {
			ret._params.insertBack (_st);
			ret._attribs.insertBack (it.token.str);
			printed = true;			
		    }		    
		}
		if (!printed) {
		    ret._params.insertBack (it.getType ());
		    ret._attribs.insertBack (it.token.str);
		}		
	    }
	}
       

	return ret;
    }    

    override StructCstInfo TempOp (Array!Expression templates) {
	Array!InfoType types;

	auto res = TemplateSolver.solve (this._tmps, templates);
	if (!res.valid) return null;

	string name = this._name;
	name ~= "!(";
	uint it = 0;
	foreach (it_ ; this._tmps) { // Il faut qu'il soit dans le bon ordre
	    foreach (key, value ; res.elements) {
		if (key == it_.token.str) {
		    types.insertBack (value.info.type);
		    name ~= value.info.type.typeString;
		    if (it != res.elements.length - 1)
			name ~= ", ";
		    it ++;
		}
	    }
	}
	
	name ~= ")";		
	auto str = FrameTable.instance.existStruct (name);
	if (str) return str;
	
	writeln ("TEMPOP : ", Table.instance.globalNamespace);
	auto ret = new StructCstInfo (Table.instance.programNamespace, name, make!(Array!Expression));
	ret._oldTmps = types;
	ret._isPublic = this._isPublic;
	
	foreach (it_ ; this._params) {
	    ret.addAttrib (cast (TypedVar) it_.templateExpReplace (res.elements));
	}
	
	FrameTable.instance.insert (ret);
	return ret;
    }
    
    /**
     Returns: false
     */
    override bool isSame (InfoType ot) {
	if (auto stcst = cast (StructCstInfo) ot) {
	    return stcst.name == this._name;
	}
	return false;
    }

    /**
     Returns: this;
     */
    override InfoType clone () {
	return this;
    }

    override Expression toYmir () {
	assert (false);
    }

    /**
     Assert: Impossible de se retrouver la.
     */
    override InfoType cloneForParam () {
	assert (false, "constructeur de structure en param !?!");
    }

    private ApplicationScore emptyCall (Word token) {
	token.str = this._name;
	auto ret = this.create (token);
	ret.lintInstMult = &StructUtils.InstCallEmpty;
	auto score = new ApplicationScore (token);
	if (this._extern) 
	    ret.leftTreatment = &StructUtils.InstCreateCstEmpty!true;
	else
	    ret.leftTreatment = &StructUtils.InstCreateCstEmpty!false;
	score.dyn = true;
	score.ret = ret;
	return score;
    }
    
    /**
     On utilise la constructeur de la structure pour générer un instance 
     Params:
     token = le constructeur
     params = les paramètres passé à la structure
     */
    override ApplicationScore CallOp (Word token, ParamList params) {
	if (!this._isPublic && !this._namespace.isSubOf (Table.instance.templateScope))
	    return null;
	
	if (params.length == 0) return emptyCall (token);
	if (params.params.length != this._params.length) {
	    return null;
	}

	Array!InfoType types;
	Array!string names;
	auto score = new ApplicationScore (token);
	foreach (it ; 0 .. this._params.length) {
	    auto info = this._params [it].getType ();
	    types.insertBack (info);
	    names.insertBack (this._params [it].token.str);
	    auto type = params.params [it].info.type.CompOp (info);
	    if (info.isSame (type)) {
		score.score += Frame.SAME;
		score.treat.insertBack (type);
	    } else if (type !is null) {
		score.score += Frame.AFF;
		score.treat.insertBack (type);
	    } else return null;
	}
	
	auto ret = StructInfo.create (this._namespace, this._name, names, types, this._oldTmps, this._methods);
	ret.lintInstMult = &StructUtils.InstCall;
	if (this._extern) 
	    ret.leftTreatment = &StructUtils.InstCreateCst!true;
	else
	    ret.leftTreatment = &StructUtils.InstCreateCst!false;
	score.dyn = true;
	score.ret = ret;
	return score;
    }
    
    /**
     Returns: le nom pour le mangling
     */
    override string simpleTypeString () {
	return format ("%d%s%s", this._name.length, "ST", this.name);
    }    

    /**
     Returns: le nom complet pour les informations d'erreur
     */
    override string innerTypeString () {
	auto name = "typeof " ~ this._namespace.toString ~ "." ~ this._name ~ "(";
	if (this._types.empty) {	    
	    foreach (it ; this._params) {
		if (auto _st = cast(StructCstInfo) it.getType ())
		    name ~= _st.name ~ "(...)";
		else if (auto _st = cast (StructInfo) it.getType ())
		name ~= _st.name ~ "(...)";
		else
		    name ~= it.getType ().innerTypeString ();
		if (it !is this._params [$ - 1]) name ~= ", ";
	    }
	} else {
	    foreach (it ; this._types) {
		if (auto _st = cast(StructCstInfo) it)
		    name ~= _st.name ~ "(...)";
		else if (auto _st = cast (StructInfo) it)
		    name ~= _st.name ~ "(...)";
		else
		    name ~= it.innerTypeString ();
		if (it !is this._types [$ - 1]) name ~= ", ";
	    }
	}
	name ~= ")";
	return name;
    }    

    /**
     Returns: la taille (même si ca veut rien dire)
     */
    override LSize size () {
	return LSize.LONG;
    }

    /**
     Supprime le constructeur de la table des structures.
     */
    override void quit (Namespace) {
	InfoType.removeCreator (this._name);
    }

    override bool isScopable () {
	return true;
    }
    
}

/**
 Une instance construite d'une structure
 */
class StructInfo : InfoType {

    private Namespace _namespace;
    
    /** Les types des paramètres de la structure */    
    private Array!InfoType _params;

    /** Les noms de attributs de la structure */
    private Array!string _attribs;
    
    private Array!InfoType _tmps;

    // Les méthodes
    private Array!MethodInfo _methods;

    // Les methodes statiques
    private Array!FunctionInfo _statics;

    // Les informations de l'ancêtre.
    private StructInfo _ancestor;
    
    /** Le nom de la structure */    
    private string _name;

    /** La structure a été importé */
    private bool _extern;

    /++ Tout les appels se font de manière statique +/
    private bool _simple;

    private this (bool isConst, Namespace space, string name, Array!string names, Array!InfoType params, Array!InfoType olds, Array!MethodInfo meth) {
	super (isConst);
	this._namespace = space;
	this._name = name;
	this._attribs = names;
	this._params = params;
	this._tmps = olds;
	this._methods = meth;
    }

    /**
     Returns: la structure a été importé
     */
    ref bool isExtern () {
	return this._extern;
    }

    /**
     Créé une instance de la structure
     Params:
     space = l'emplacement de la création de la structure
     name = le nom de la structure
     names = les noms des attributs
     params = les types des attributs
     */
    static InfoType create (Namespace space, string name, Array!string names, Array!InfoType params, Array!InfoType olds, Array!MethodInfo meths) {
	return new StructInfo (false, space, name, names, params, olds, meths);
    }

    
    /**
     Returns: les types des attributs de la structure
     */
    ref Array!InfoType params () {
	return this._params;
    }

    ref Array!MethodInfo methods () {
	return this._methods;
    }
    
    ref Array!string attribs () {
	return this._attribs;
    }

    ref StructInfo ancestor () {
	return this._ancestor;
    }
    
    void setStatics (Array!FunctionInfo funs) {
	this._statics = funs;
    }

    void setMethods (Array!MethodInfo funs) {
	this._methods = funs;
    }
    
    Namespace namespace () {
	return this._namespace;
    }
    
    /**
     Returns: le nom de la structure
     */    
    string name () {
	return this._name;
    }    

    /**
     Surcharge des operateur binaire sur une structure
     Params: 
     token = l'operateur
     right = l'operande droite
     */
    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	if (token == Keys.IS) return Is (right);
	else if (token == Keys.NOT_IS) return NotIs (right);
	return null;
    }

    /**
     Surcharge des operateurs binaire à droite.
     Params:
     token = l'operateur
     left = l'operande gauche
     */
    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	return null;
    }

    /**
     Surcharge de l'operateur 'is'.
     Sur une structure is permet de verifier que le structure n'est pas null ou de verifier son type
     Returns: une instance de BoolInfo, ou null
     */
    private InfoType Is (Expression right) {
	if (this.isSame (right.info.type)) {
	    auto b = new BoolInfo (true);
	    b.lintInst = &StructUtils.InstEqual;
	    return b;
	} else if (auto _cst = cast (StructCstInfo) right.info.type) {
	    auto b = new BoolInfo (true);
	    if (_cst.name == this._name) b.lintInst = &BoolUtils.InstTrue;
	    else b.lintInst = &BoolUtils.InstFalse;
	    return b;
	} else if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto b = new BoolInfo (true);
	    b.lintInst = &StructUtils.InstEqual;
	    return b;	    
	}
	return null;
    }    

    /**
     Surcharge de l'operateur '!is'.
     Cf: Is
     Returns: une instance de BoolInfo, ou null
     */
    private InfoType NotIs (Expression right) {
	if (this.isSame (right.info.type)) {
	    auto b = new BoolInfo (true);
	    b.lintInst = &StructUtils.InstNotEqual;
	    return b;
	} else if (auto _cst = cast (StructCstInfo) right.info.type) {
	    auto b = new BoolInfo (true);
	    if (_cst.name == this._name) b.lintInst = &BoolUtils.InstFalse;
	    else b.lintInst = &BoolUtils.InstTrue;
	    return b;
	} else if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto b = new BoolInfo (true);
	    b.lintInst = &StructUtils.InstNotEqual;
	    return b;
	}
	return null;
    }    

    /**
     Surcharge de l'operateur '='.
     Returns: une instance de StructInfo ou null
     */
    private InfoType Affect (Expression right) {
	auto _st = cast (StructInfo) right.info.type;
	if (_st && _st.name == this._name) {
	    auto other = this.clone ();
	    other.lintInst = &StructUtils.InstAffect;
	    return other;
	} else if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto other = this.clone ();
	    other.lintInst = &StructUtils.InstAffectNull;
	    return other;	    
	} else if (_st) {
	    if (_st.ancestor) {
		if (auto type = _st.ancestor.CompOp (this)) {
		    type.lintInst = &StructUtils.InstAffect;
		    return type;
		} 		    
	    }
	}
	return null;
    }

    /**
     Surcharge de l'operateur '=' à droite.
     Returns: une instance de StructInfo, ou null
     */
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto other = this.clone ();
	    other.lintInst = &ClassUtils.InstAffectRight;
	    return other;
	} else if (this._ancestor) {
	    if (auto type = this._ancestor.CompOp (left.info.type)) {
		type.lintInst = &ClassUtils.InstAffectRight;
		return type;
	    } else if (auto type = left.info.type.CompOp (this._ancestor)) {
		type.lintInst = &ClassUtils.InstAffectRight;
		return type;
	    }
	} else if (auto str = cast (StructInfo) left.info.type) {
	    if (str._ancestor) {
		if (auto type = str._ancestor.CompOp (this)) {
		    type.lintInst = &ClassUtils.InstAffectRight;
		    return type;
		}
	    }
	}
	return null;
    }    

    /**
     Surcharge de l'operateur '.'
     StructInfo surcharge 'init' et 'typeid' comme propriété.
     On peut aussi acceder au attributs de cette manière.
     */
    override InfoType DotOp (Var var) {
	if (var.templates.length == 0) {
	    if (var.token.str == "init") return Init ();
	    else if (var.token.str == "typeid") return StringOf ();
	    else if (var.token.str == "typename") return TypeName ();
	    else if (var.token.str == "tupleof") return TupleOf ();
	    else if (var.token.str == "ptr") return Ptr ();
	    else if (var.token.str == "sizeof") return SizeOf ();
	    else if (var.token.str == "super") return Super ();
	}
	
	foreach (it ; 0 .. this._attribs.length) {
	    if (var.token.str == this._attribs [it]) {
		return GetAttrib (it);
	    }
	}

	foreach (it ; 0 .. this._methods.length) {
	    if (var.token.str == this._methods [it].name) {
		if (!this._methods [it].isOverride)
		    return GetMethod (it);
	    }
	}

	if (this._ancestor) {
	    return this._ancestor.DotOp (var);
	} else 	
	    return null;
    }

    /++
     Surcharge de l'operateur '::'
     Params:
     var = l'élement à droite de l'expression
     Returns: une fonction statique ou null.
     +/
    override InfoType DColonOp (Var var) {
	if (this._isType) {
	    foreach (it ; this._statics) {
		if (it.name == var.token.str) {
		    return it;
		}
	    }
	}
	return null;
    }
    
    /**
     Surcharge du cast automatique     
     */
    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || this.isSame (other)) {
	    auto ret = this.clone ();
	    ret.lintInst = &StructUtils.InstAffectRight;
	    return ret;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (this.isSame(_ref.content) && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS.insertBack (&StructUtils.InstAddr);
		return aux;
	    }
	}
	
	if (this._ancestor) {
	    if (auto type = this._ancestor.CompOp (other))
		return type;
	    else if (auto type = other.CompOp (this._ancestor))
		return type;
	    
	}
	return null;
    }

    /**
       Surcharge de l'operateur de cast       
       Params:
       other = le type vers lequel on veut caster
     */
    override InfoType CastOp (InfoType other) {
	if (auto obj = cast (ObjectCstInfo) other) {
	    auto str = obj.create ();
	    if (this.isAncestor (str)) {
		auto ret = str.clone ();
		ret.lintInst = &StructUtils.InstAffect;
		return ret;
	    }
	}
	return null;
    }        

    private bool isAncestor (StructInfo str) {
	if (this.isSame (str)) return true;
	else if (str.ancestor) {
	    return this.isAncestor (str.ancestor);
	}
	return false;
    }    
    
    /**
     Traitement à appliquer quand on passe le structure en paramètre.
     Returns: le type contenant le traitement.
     */
    override InfoType ParamOp () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&ClassUtils.InstParam);
	return ret;
    }

    /**
     Traitement à appliquer quand on retourne la structure
     Returns: le type contenant le traitement.
     */
    override InfoType ReturnOp () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&ClassUtils.InstReturn);
	return ret;
    }    

    /**
     Valeur d'init d'une structure
     */
    private InfoType Init () {
	auto t = this.clone ();
	t.lintInst = &StructUtils.Init;
	return t;
    }

    private InfoType TupleOf () {
	Array!InfoType params;
	foreach (it ; this._params)
	    params.insertBack (it.clone ());
	auto t = new TupleInfo (this.isConst);
	t.params = params;
	t.leftTreatment = &StructUtils.GetTupleOf;
	t.lintInst = &StructUtils.InstTupleOf;
	return t;
    }
    
    private InfoType Ptr () {
	auto ret = new PtrInfo (this.isConst, new VoidInfo);
	ret.lintInst = &StructUtils.InstPtr;
	return ret;
    }

    private InfoType SizeOf () {
	auto ret = new DecimalInfo (true, DecimalConst.UBYTE);
	ret.lintInst = &StructUtils.SizeOf;
	ret.leftTreatment = &StructUtils.GetSizeOf;
	return ret;
    }

    private InfoType Super () {
	if (this._ancestor) {
	    auto ret = cast (StructInfo) this._ancestor.clone ();
	    ret.lintInst = &StructUtils.InstGetSuper;
	    ret.simplify ();
	    return ret;
	} else return null;
    }

    private void simplify () {
	this._simple = true;
	if (this._ancestor)
	    this._ancestor.simplify ();
    }
    
    /**
     surcharge de la propriété typeid.
     */
    private InfoType StringOf () {
	auto str = new StringInfo (true);
	str.value = new StringValue (this.typeString);
	return str;
    }

    /**
     surcharge de la propriété typeid.
     */
    private InfoType TypeName () {
	auto str = new StringInfo (true);
	str.value = new StringValue (this._name);
	return str;
    }
       
    /**
     Accés à un paramètre de la structure.
     */
    private InfoType GetAttrib (ulong nb) {
	auto type = this._params [nb].clone ();
	if (auto _cst = cast (StructCstInfo) type) {
	    auto word = Word.eof;
	    word.str = _cst._name;
	    type = _cst.create (word);
	}

	type.toGet = nb;
	if (this._ancestor) {
	    type.toGet += this._ancestor.getNbAttrib;
	}
	
	type.lintInst = &StructUtils.Attrib;
	type.leftTreatment = &StructUtils.GetAttrib;
	type.isConst = false;
	return type;
    }    

    private ulong getNbAttrib () {
	if (this._ancestor) {
	    return this._params.length + this._ancestor.getNbAttrib ();
	} else return this._params.length;
    }
    
    private InfoType GetMethod (ulong nb) {
	if (!this._simple && cast (PureFrame) this._methods [nb].frame) {
	    auto proto = this._methods [nb].frame.validate ();
	    auto ret = new PtrFuncInfo (true);
	    Array!InfoType infos;
	    foreach (it ; proto.vars) infos.insertBack (it.info.type);
	    ret.params = infos;
	    ret.ret = proto.type.type;
	    ret.toGet = computeMethPos (nb);
	    if (this._ancestor)
		ret.toGet += this._ancestor.getNbMethod ();
	    
	    ret.lintInst = &StructUtils.Method;
	    ret.leftTreatment = &StructUtils.GetMethod;
	    return ret;
	} else {
	    auto fr = this._methods [nb].frame;
	    auto ret = new MethodInfo (fr.namespace, fr.ident.str, fr);
	    return ret;
	}
    }

    ulong nbMethods () {
	return computeMethPos (this._methods.length);
    }
    
    private ulong computeMethPos (ulong nb) {
	ulong ret = 0;
	foreach (it ; 0 .. nb) {
	    if (cast (PureFrame) this._methods [it].frame
		&& !this._methods [it].isOverride
	    ) ret ++;
	}
	return ret;
    }
    
    private ulong getNbMethod () {
	if (this._ancestor) {
	    return computeMethPos (this._methods.length) + this._ancestor.getNbMethod ();
	} else return computeMethPos (this._methods.length);
    }
    
    /**
     Les deux types sont ils identique ?
     */
    override bool isSame (InfoType other) {
	auto type = cast (StructInfo) other;
	if (type && type._name == this._name) {
	    return true;
	}
	return false;
    }

    /**
     Returns: le nom complet pour les informations d'erreur.
     */
    override string innerTypeString () {
	auto name = this._namespace.toString ~ "." ~ this._name ~ "(";
	foreach (it ; this._params) {
	    if (auto _st = cast(StructCstInfo) it)
		name ~= _st.name ~ "(...)";
	    else if (auto _st = cast (StructInfo) it)
		name ~= _st.name ~ "(...)";
	    else
		name ~= it.innerTypeString ();
	    if (it !is this._params [$ - 1]) name ~= ", ";
	}
	name ~= ")";
	return name;
    }

    /**
     Returns: le nom pour le mangling.
     */
    override string simpleTypeString () {
	return format ("%d%s%s", this._name.length, "ST", this._name);
    }    

    /**
     Returns: une nouvelle instance de StructInfo, avec les informations de destruction concervées.
     */
    override InfoType clone () {
	auto ret = cast (StructInfo) create (this._namespace, this._name, this._attribs, this._params, this._tmps, this._methods);
	ret._statics = this._statics;
	ret._ancestor = this._ancestor;
	ret._simple = this._simple;
	ret.isConst = this.isConst;
	return ret;
    }

    override Expression toYmir () {
	Word w = Word.eof ();
	w.str = this._name;
	return new Type (w, this.clone ());
    }

    /**
     Returns: une nouvelle instance de StructInfo, avec les informations de destruction remise à zero.
    */
    override InfoType cloneForParam () {
	auto ret = cast (StructInfo) create (this._namespace, this._name, this._attribs, this._params, this._tmps, this._methods);
	ret._statics = this._statics;
	ret._ancestor = this._ancestor;
	return ret;
    }

    override InfoType getTemplate (ulong id) {
	if (id < this._tmps.length)
	    return this._tmps [id];
	return null;
    }
    
    /**
     Returns: la taille en mémoire du type.
     */
    override LSize size () {
	return LSize.ULONG;
    }
   
}
