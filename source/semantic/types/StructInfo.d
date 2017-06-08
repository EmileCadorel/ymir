module semantic.types.StructInfo;
import semantic.types.InfoType;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.StructUtils, syntax.Keys;
import semantic.types.BoolInfo;
import semantic.types.UndefInfo, lint.LSize;
import semantic.types.NullInfo, std.stdio;
import std.container, semantic.types.FunctionInfo, std.outbuffer;
import ast.ParamList, semantic.pack.Frame, semantic.types.StringInfo;
import semantic.pack.Table, utils.exception, semantic.types.ClassUtils;
import semantic.types.BoolUtils, semantic.types.RefInfo;
import semantic.types.DecimalInfo;
import ast.Constante;
import semantic.pack.Namespace;

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
    
    /** 
     Ajoute un attributs à la structure
     Params:
     type = l'attribut (doit avoir été analysé sémantiquement)
     */
    void addAttrib (TypedVar type) {
	this._params.insertBack (type);
    }

    bool needCreation () {
	return this._tmps.length == 0;
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
	import std.format, ast.FuncPtr, ast.ArrayAlloc;
	if (name.str in __creations__)
	    throw new RecursiveCreation (name);
	
	auto cst = cast(StructCstInfo) (Table.instance.get (name.str).type);

	__creations__ [name.str] = cst;
	scope (exit) __creations__.remove (name.str);
	
	if (cst is null) assert (false, "Nooooon !!!");
	if (cst._tmps.length == 0 && templates.length != 0)
	    throw new NotATemplate (name);

	if (cst._tmps.length != 0) {
	    auto ret = cst.TempOp (make!(Array!Expression) (templates));
	    if (ret is null) throw new NotATemplate (name, make!(Array!Expression) (templates));
	    return ret.emptyCall (name).ret;
	}
	
	if (cst._types.empty) {	    	    
	    foreach (it ; cst._params) {
		auto printed = false;
		Symbol sym;
		if (auto fn = cast (FuncPtr) it.expType) {
		    auto type = fn.expression;
		    sym = type.info;
		} else if (auto array = cast (ArrayAlloc) it.expType) {
		    assert (false, "TODO");
		} else {
		    sym = Table.instance.get (it.type.token.str);
		    if (sym is null) it.type.asType ();
		}
		if (sym) {
		    auto _st = cast (StructCstInfo) (sym.type);
		    if (_st) {
			cst._types.insertBack (_st);
			cst._names.insertBack (it.token.str);
			printed = true;			
		    }		    
		}
		if (!printed) {
		    cst._types.insertBack (it.getType ());
		    cst._names.insertBack (it.token.str);
		}		
	    }
	}
	
	auto ret = cast (StructInfo) StructInfo.create (cst._namespace, cst._name, cst._names, cst._types, cst._oldTmps);
	ret.isExtern = cst._extern;
	return ret;
    }

    InfoType create (Word name) {
	import std.format, ast.FuncPtr, ast.ArrayAlloc;
	if (this._types.empty) {	    	    
	    foreach (it ; this._params) {
		auto printed = false;
		Symbol sym;
		if (auto fn = cast (FuncPtr) it.expType) {
		    auto type = fn.expression;
		    sym = type.info;
		} else if (auto array = cast (ArrayAlloc) it.expType) {
		    assert (false, "TODO");
		} else {
		    sym = Table.instance.get (it.type.token.str);
		    if (sym is null) it.type.asType ();
		}
		if (sym) {
		    auto _st = cast (StructCstInfo) (sym.type);
		    if (_st) {
			this._types.insertBack (_st);
			this._names.insertBack (it.token.str);
			printed = true;			
		    }		    
		}
		if (!printed) {
		    this._types.insertBack (it.getType ());
		    this._names.insertBack (it.token.str);
		}		
	    }
	}
       
	auto ret = cast (StructInfo) StructInfo.create (this._namespace, this._name, this._names, this._types, this._oldTmps);
	ret.isExtern = this._extern;
	return ret;
    }    

    override StructCstInfo TempOp (Array!Expression templates) {
	import semantic.pack.FrameTable, semantic.pack.TemplateSolver;
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
	
	auto ret = new StructCstInfo (this._namespace, name, make!(Array!Expression));
	ret._oldTmps = types;
	foreach (it_ ; this._params) {
	    ret.addAttrib (cast (TypedVar) it_.templateExpReplace (res.elements));
	}
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
	
	auto ret = StructInfo.create (this._namespace, this._name, names, types, this._oldTmps);
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
	import std.format;
	return format ("%d%s%s", this._name.length, "ST", this.name);
    }    

    /**
     Returns: le nom complet pour les informations d'erreur
     */
    override string typeString () {
	auto name = "typeof " ~ this._name ~ "(";
	if (this._types.empty) {	    
	    foreach (it ; this._params) {
		if (auto _st = cast(StructCstInfo) it.getType ())
		    name ~= _st.name ~ "(...)";
		else if (auto _st = cast (StructInfo) it.getType ())
		name ~= _st.name ~ "(...)";
		else
		    name ~= it.getType ().typeString ();
		if (it !is this._params [$ - 1]) name ~= ", ";
	    }
	} else {
	    foreach (it ; this._types) {
		if (auto _st = cast(StructCstInfo) it)
		    name ~= _st.name ~ "(...)";
		else if (auto _st = cast (StructInfo) it)
		    name ~= _st.name ~ "(...)";
		else
		    name ~= it.typeString ();
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
    
    /** Le nom de la structure */    
    private string _name;

    /** La structure a été importé */
    private bool _extern;

    private this (Namespace space, string name, Array!string names, Array!InfoType params, Array!InfoType olds) {
	this._namespace = space;
	this._name = name;
	this._attribs = names;
	this._params = params;
	this._tmps = olds;
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
    static InfoType create (Namespace space, string name, Array!string names, Array!InfoType params, Array!InfoType olds) {
	return new StructInfo (space, name, names, params, olds);
    }

    
    /**
     Returns: les types des attributs de la structure
     */
    ref Array!InfoType params () {
	return this._params;
    }

    ref Array!string attribs () {
	return this._attribs;
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
	    auto b = new BoolInfo ();
	    b.lintInst = &StructUtils.InstEqual;
	    return b;
	} else if (auto _cst = cast (StructCstInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    if (_cst.name == this._name) b.lintInst = &BoolUtils.InstTrue;
	    else b.lintInst = &BoolUtils.InstFalse;
	    return b;
	} else if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto b = new BoolInfo ();
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
	    auto b = new BoolInfo ();
	    b.lintInst = &StructUtils.InstNotEqual;
	    return b;
	} else if (auto _cst = cast (StructCstInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    if (_cst.name == this._name) b.lintInst = &BoolUtils.InstFalse;
	    else b.lintInst = &BoolUtils.InstTrue;
	    return b;
	} else if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto b = new BoolInfo ();
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
	}
	
	foreach (it ; 0 .. this._attribs.length) {
	    if (var.token.str == this._attribs [it]) {
		return GetAttrib (it);
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
	return null;
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
	import semantic.types.TupleInfo;
	Array!InfoType params;
	foreach (it ; this._params)
	    params.insertBack (it.clone ());
	auto t = new TupleInfo ();
	t.params = params;
	t.lintInst = &StructUtils.InstTupleOf;
	return t;
    }

    private InfoType Ptr () {
	import semantic.types.PtrInfo, semantic.types.VoidInfo;
	auto ret = new PtrInfo (new VoidInfo);
	ret.lintInst = &StructUtils.InstPtr;
	return ret;
    }

    private InfoType SizeOf () {
	import semantic.types.DecimalInfo, ast.Constante;
	auto ret = new DecimalInfo (DecimalConst.UBYTE);
	ret.lintInst = &StructUtils.SizeOf;
	ret.leftTreatment = &StructUtils.GetSizeOf;
	return ret;
    }
    
    /**
     surcharge de la propriété typeid.
     */
    private InfoType StringOf () {
	auto str = new StringInfo;
	str.value = new StringValue (this.typeString);
	return str;
    }

    /**
     surcharge de la propriété typeid.
     */
    private InfoType TypeName () {
	auto str = new StringInfo;
	str.value = new StringValue (this._name);
	return str;
    }
       
    /**
     Accés à un paramètre de la structure.
     */
    private InfoType GetAttrib (ulong nb) {
	import std.array;
	auto type = this._params [nb].clone ();
	if (auto _cst = cast (StructCstInfo) type) {
	    auto word = Word.eof;
	    word.str = _cst._name;
	    type = _cst.create (word);
	}
	type.toGet = nb;
	type.lintInst = &StructUtils.Attrib;
	type.leftTreatment = &StructUtils.GetAttrib;
	type.isConst = false;
	return type;
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
    override string typeString () {
	auto name = this._name ~ "(";
	foreach (it ; this._params) {
	    if (auto _st = cast(StructCstInfo) it)
		name ~= _st.name ~ "(...)";
	    else if (auto _st = cast (StructInfo) it)
		name ~= _st.name ~ "(...)";
	    else
		name ~= it.typeString ();
	    if (it !is this._params [$ - 1]) name ~= ", ";
	}
	name ~= ")";
	return name;
    }

    /**
     Returns: le nom pour le mangling.
     */
    override string simpleTypeString () {
	import std.format;
	return format ("%d%s%s", this._name.length, "ST", this._name);
    }    

    /**
     Returns: une nouvelle instance de StructInfo, avec les informations de destruction concervées.
     */
    override InfoType clone () {
	return create (this._namespace, this._name, this._attribs, this._params, this._tmps);
    }

    /**
     Returns: une nouvelle instance de StructInfo, avec les informations de destruction remise à zero.
    */
    override InfoType cloneForParam () {
	return create (this._namespace, this._name, this._attribs, this._params, this._tmps);
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
