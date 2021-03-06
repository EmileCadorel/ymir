module ymir.semantic.types.RangeInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container;

/**
 Classe contenant les informations du type range.
 */
class RangeInfo : InfoType {

    /** Le type contenu dans le type range  */
    private InfoType _content;
    
    this (bool isConst) {
	super (isConst);
    }

    /**
     Params:
     content = le type contenu dans le type range.
     */
    this (bool isConst, InfoType content) {
	super (isConst);
	this._content = content;
    }

    /**
     Returns: le type contenu.
     */
    InfoType content() {
	return this._content;
    }

    /**
     Returns: Une nouvelle instance de range (les informations de destruction sont consérvées).
     */
    override InfoType clone () {
	auto ret = new RangeInfo (this.isConst, this._content.clone ());
	ret.value = this._value;
	return ret;
    }

    override Expression toYmir () {
	Word w = Word.eof;
	w.str = "r";
	auto ret = new Var (w, make!(Array!Expression) (this._content.toYmir ()));
	ret.info = new Symbol (w, this.clone ());
	return ret;
    }

    /**
     Returns: une nouvelle instance de range (les informations de destruction sont remisent à zéro).
     */
    override InfoType cloneForParam () {
	return new RangeInfo (this.isConst, this._content.clone ());
    }

    /**
     Params:
     other = le deuxieme type.
     Returns: les types sont identique ?
     */
    override bool isSame (InfoType other) {
	if (auto _r = cast (RangeInfo) other) {
	    return _r._content.isSame (this._content);
	}
	return false;
    }

    /**
     Créé une instance de type range en fonction de ses paramètre templates.
     Params:
     token = l'identificateur de création.
     templates = les paramères templates de l'identificateur.
     Returns: Une instance de range.
     Throws: UndefinedType
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast (Type) templates [0])) {
	    throw new UndefinedType (token, "prend un type primitif en template");
	} else {
	    auto type = templates [0].info.type;
	    if (!(cast (FloatInfo)  type)  && !(cast (CharInfo) type) && !(cast (DecimalInfo) type))
		throw new UndefinedType (token, "prend un type primitif en template");
	    auto arr = new RangeInfo (false, templates [0].info.type);
	    return arr;
	}
    }

    
    /**
     Surcharge des operateurs binaire du type.
     Params:
     token = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Keys.IS) return Is (right);	
	else if (token == Keys.NOT_IS) return NotIs (right);
	else if (token == Tokens.EQUAL) return Affect (right);
	return null;
    }

    /**
     Surcharge des operateurs binaire à droite.
     Params:
     token = l'operateur.
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOpRight (Word token, Expression left) {
	if (token == Tokens.EQUAL) return AffectRight (left);
	else if (token == Keys.IN) return In (left);       
	return null;
    }

    /**
     Operateur '=' à droite.
     Params:
     left = l'operande gauche de l'expression.
     Returns: le type résultat de l'expression.
     */
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ret = this.clone ();
	    ret.value = null;
	    ret.lintInst = &RangeUtils.InstAffectRight;	    
	    return ret;
	}
	return null;
    }

    /**
     Operateur '='.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat de l'expression.
     */
    private InfoType Affect (Expression right) {
	if (cast (NullInfo) right.info.type) {
	    auto ret = this.clone ();
	    ret.value = null;
	    ret.lintInst = &ClassUtils.InstAffectNull;
	    return ret;
	} else if (this.isSame (right.info.type)) {
	    auto ret = this.clone ();
	    ret.value = null;
	    ret.lintInst = &ClassUtils.InstAffect;
	    return ret;
	}
	return null;
    }

    /**
     Operateur 'is'.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType Is (Expression right) {
	if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &ClassUtils.InstIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &ClassUtils.InstIs;
	    return ret;
	}
	return null;
    }

    /**
     Operateur '!is'.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
    */
    private InfoType NotIs (Expression right) {
	if (auto _ptr = cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &ClassUtils.InstNotIsNull;
	    return ret;	    
	} else if (this.isSame (right.info.type)) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &ClassUtils.InstNotIs;
	    return ret;
	}
	return null;
    }    

    /**
     Operateur 'in'.
     Params:
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType In (Expression left) {
	if (this._content.isSame (left.info.type)) {
	    auto ret = new BoolInfo (true);
	    final switch (this._content.size.id) {
	    case LSize.BYTE.id: ret.lintInst =  (&RangeUtils.InstIn!(LSize.BYTE)); break;
	    case LSize.UBYTE.id: ret.lintInst =  (&RangeUtils.InstIn!(LSize.UBYTE)); break;
	    case LSize.SHORT.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.SHORT)); break;
	    case LSize.USHORT.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.USHORT)); break;
	    case LSize.INT.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.INT)); break;
	    case LSize.UINT.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.UINT)); break;
	    case LSize.LONG.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.LONG)); break;
	    case LSize.ULONG.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.ULONG)); break;
	    case LSize.FLOAT.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.FLOAT)); break;
	    case LSize.DOUBLE.id: ret.lintInst = (&RangeUtils.InstIn!(LSize.DOUBLE)); break;
	    }
	    if (this._value)		
		ret.value = this._value.BinaryOpRight (Keys.IN, left.info.type.value);
	    return ret;
	}
	return null;
    }

    /**
     Surcharge de l'operateur d'accés au attributs.
     Params:
     var = l'attribut demandé.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.templates.length != 0) return null;
	if (var.token.str == "fst") return Fst ();
	if (var.token.str == "scd") return Scd ();
	return null;
    }

    /**
     Attribut 'fst'.
     Returns: une instance du type contenu.
     */
    private InfoType Fst () {
	auto cst = this._content.clone ();
	cst.isConst = this.isConst;
	final switch (cst.size.id) {
	case LSize.BYTE.id: cst.lintInst =  (&RangeUtils.InstFst!(LSize.BYTE)); break;
	case LSize.UBYTE.id: cst.lintInst =  (&RangeUtils.InstFst!(LSize.UBYTE)); break;
	case LSize.SHORT.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.SHORT)); break;
	case LSize.USHORT.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.USHORT)); break;
	case LSize.INT.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.INT)); break;
	case LSize.UINT.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.UINT)); break;
	case LSize.LONG.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.LONG)); break;
	case LSize.ULONG.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.ULONG)); break;
	case LSize.FLOAT.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.FLOAT)); break;
	case LSize.DOUBLE.id: cst.lintInst = (&RangeUtils.InstFst!(LSize.DOUBLE)); break;		    
	}
	return cst;
    }

    
    /**
     Attribut 'scd'.
     Returns: une instance du type contenu.
     */
    private InfoType Scd () {
	auto cst = this._content.clone ();
	cst.isConst = this.isConst;
	final switch (cst.size.id) {
	case LSize.BYTE.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.BYTE)); break;
	case LSize.UBYTE.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.UBYTE)); break;
	case LSize.SHORT.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.SHORT)); break;
	case LSize.USHORT.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.USHORT)); break;
	case LSize.INT.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.INT)); break;
	case LSize.UINT.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.UINT)); break;
	case LSize.LONG.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.LONG)); break;
	case LSize.ULONG.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.ULONG)); break;
	case LSize.FLOAT.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.FLOAT)); break;
	case LSize.DOUBLE.id: cst.lintInst = (&RangeUtils.InstScd!(LSize.DOUBLE)); break;		    
	}
	return cst;
    }

    /**
     Surcharge de l'operateur d'iteration.
     Params:
     vars = les iterateurs.
     Returns: le type résultat ou null.
     */
    override InfoType ApplyOp (Array!Var vars) {
	if (vars.length != 1) return null;
	vars [0].info.type = this._content.clone ();
	vars [0].info.type.isConst = true;
	auto ret = this.clone ();
	ret.leftTreatment = &RangeUtils.InstApplyPreTreat;
	ret.lintInst = &RangeUtils.InstApply;
	return ret;
    }

    /**
     Returns: le nom du type.
     */
    override string innerTypeString () {
	return "range!" ~ this._content.innerTypeString;
    }

    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	return "r_" ~ this._content.simpleTypeString;
    }
    
    /**
     Returns: La taille mémoire du type.
     */
    override LSize size () {
	return LSize.ULONG;
    }

    /**
     Returns: la taille mémoire du type.
     */
    static LSize sizeOf () {
	return LSize.ULONG;
    }

    /**
     Returns: le traitement à éffectuer en début de fonction pour le paramètre de type range.
     */
    override InfoType ParamOp () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&ClassUtils.InstParam);
	return ret;
    }

    /**
     Returns: le traitment à éffectuer pour l'operateur de retour sur le type range.
     */
    override InfoType ReturnOp () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&ClassUtils.InstReturn);
	return ret;
    }

    /**
     Surcharge de l'operateur de cast automatique.
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || this.isSame (other)) {
	    auto ra = this.clone ();
	    ra.value = null;
	    ra.lintInst = &RangeUtils.InstAffectRight;
	    return ra;
	} else if (auto en = cast (EnumInfo) other) {
	    return this.CompOp (en.content);
	} 
	return null;
    }

    override InfoType getTemplate (ulong i) {
	if (i == 0) return this._content;
	return null;
    }
    
}
