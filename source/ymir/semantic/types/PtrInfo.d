module ymir.semantic.types.PtrInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container;

/**
 Classe contenant les informations sur un type pointeur.
 */
class PtrInfo : InfoType {

    /** le type contenu dans le pointeur */
    private InfoType _content = null;

    this (bool isConst) {
	super (isConst);
	this._content = new VoidInfo ();
    }

    /** 
     Params:
    content = le type à mettre dans le ptr.
    */
    this (bool isConst, InfoType content) {
	super (isConst);
	this._content = content;
    }   

    /**
     Params:
     other = le deuxieme type.
     Returns: les deux types sont identique ?
     */
    override bool isSame (InfoType other) {
	auto ptr = cast (PtrInfo) other;
	if (ptr is null) return false;
	if (this._content is ptr.content) return true;
	return ptr.content.isSame (this._content);
    }

    /**
       this => other
       Returns: On peut passer de l'un à l'autre sans casser la verification constante ?  
     */
    override InfoType ConstVerif (InfoType other) {
	if (this.isConst && !other.isConst) return null;
	else if (!this.isConst && other.isConst)
	    this.isConst = false;
	return this;
    }
    
    /**
     Créé une instance de ptr en fonction des paramètre templates.
     Params:
     token = l'identificateur de construction.
     templates = les paramètre templates de l'identificateur.
     Returns: Une instance de ptr.
     Throws: UndefinedType
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast(Type)templates[0]))
	    throw new UndefinedType (token, "prend un type en template");
	else {
	    auto ptr = new PtrInfo (false, templates [0].info.type);
	    return ptr;
	}	
    }

    
    /**
     Surcharge des operateurs binaire du type ptr.
     Params:
     token = l'operateur.
     rigth = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	else if (token == Tokens.PLUS) return Plus (right);
	else if (token == Tokens.MINUS) return Sub (right);
	else if (token == Keys.IS) return Is (right);
	else if (token == Keys.NOT_IS) return NotIs (right);
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
	if (token == Tokens.PLUS) return PlusRight (left);
	else if (token == Tokens.MINUS) return SubRight (left);
	return null;
    }

    /**
     Surcharge des operateur unaire du type ptr.
     Params:
     op = l'operateur.
     Returns: le type résultat ou null.
     */
    override InfoType UnaryOp (Word op) {
	if (op == Tokens.STAR) return Unref ();
	else if (op == Tokens.AND && !this.isConst) return toPtr ();
	return null;
    }

    /**
     Surcharge de l'operateur '='.
     Params:
     right = l'operande droite de l'expression.
     Returns: la type résultat ou null.
     */
    private InfoType Affect (Expression right) {
	auto type = cast (PtrInfo) right.info.type;
	if (type !is null && type.content.isSame (this._content)) {
	    auto ret = new PtrInfo (false, this._content.clone ());
	    ret.lintInst = &PtrUtils.InstAffect ;
	    return ret;
	} else if (type && cast (VoidInfo) this._content) {
	    this._content = type.content.clone ();
	    auto ret = new PtrInfo (false, this._content.clone ());
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (type && cast (VoidInfo) type.content) {
	    auto ret = new PtrInfo (false, type.content.clone ());
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	} else if (cast (NullInfo) right.info.type) {
	    auto ret = this.clone ();
	    ret.lintInst = &PtrUtils.InstAffectNull;
	    return ret;
	}
	return null;
    }

    /**
     Surcharge de l'operateur '=' à droite.
     Params:
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ret = new PtrInfo (false, this._content.clone ());
	    ret.lintInst = &PtrUtils.InstAffect;
	    return ret;
	}
	return null;
    }

    /**
     Surcharge de l'operateur '+'.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     Bugs: ne marche pas avec les long.
     */
    private InfoType Plus (Expression right) {
	if (cast (DecimalInfo) right.info.type) {
	    auto ptr = new PtrInfo (this.isConst, this._content.clone ());
	    if (this._content.size == LSize.BYTE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.BYTE, Tokens.PLUS);
	    else if (this._content.size == LSize.UBYTE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.UBYTE, Tokens.PLUS);
	    else if (this._content.size == LSize.SHORT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.SHORT, Tokens.PLUS);
	    else if (this._content.size == LSize.USHORT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.USHORT, Tokens.PLUS);
	    else if (this._content.size == LSize.INT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.INT, Tokens.PLUS);
	    else if (this._content.size == LSize.UINT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.UINT, Tokens.PLUS);
	    else if (this._content.size == LSize.LONG)  ptr.lintInst = &PtrUtils.InstOp !(LSize.LONG, Tokens.PLUS);
	    else if (this._content.size == LSize.ULONG)  ptr.lintInst = &PtrUtils.InstOp !(LSize.ULONG, Tokens.PLUS);
	    else if (this._content.size == LSize.FLOAT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.FLOAT, Tokens.PLUS);
	    else if (this._content.size == LSize.DOUBLE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.DOUBLE, Tokens.PLUS);
	    else return null;
	    return ptr;
	}
	return null;
    }

    /**
     Surcharge de l'operateur '-'.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     Bugs: ne marche pas avec les long.
     */
    private InfoType Sub (Expression right) {
	if (cast (DecimalInfo) right.info.type) {
	    auto ptr = new PtrInfo (this.isConst, this._content.clone ());
	    if (this._content.size == LSize.BYTE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.BYTE, Tokens.MINUS);
	    else if (this._content.size == LSize.UBYTE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.UBYTE, Tokens.MINUS);
	    else if (this._content.size == LSize.SHORT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.SHORT, Tokens.MINUS);
	    else if (this._content.size == LSize.USHORT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.USHORT, Tokens.MINUS);
	    else if (this._content.size == LSize.INT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.INT, Tokens.MINUS);
	    else if (this._content.size == LSize.UINT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.UINT, Tokens.MINUS);
	    else if (this._content.size == LSize.LONG)  ptr.lintInst = &PtrUtils.InstOp !(LSize.LONG, Tokens.MINUS);
	    else if (this._content.size == LSize.ULONG)  ptr.lintInst = &PtrUtils.InstOp !(LSize.ULONG, Tokens.MINUS);
	    else if (this._content.size == LSize.FLOAT)  ptr.lintInst = &PtrUtils.InstOp !(LSize.FLOAT, Tokens.MINUS);
	    else if (this._content.size == LSize.DOUBLE)  ptr.lintInst = &PtrUtils.InstOp !(LSize.DOUBLE, Tokens.MINUS);
	    else return null;
	    return ptr;
	}
	return null;
    }

    /**
     Surcharge de l'operateur '+' à droite.
     Params:
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     Bugs: ne marche pas avec les long.
     */
    private InfoType PlusRight (Expression left) {
	if (cast (DecimalInfo) left.info.type) {
	    auto ptr = new PtrInfo (this.isConst, this._content.clone ());
	    if (this._content.size == LSize.BYTE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.BYTE, Tokens.PLUS);
	    if (this._content.size == LSize.UBYTE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.UBYTE, Tokens.PLUS);
	    else if (this._content.size == LSize.SHORT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.SHORT, Tokens.PLUS);
	    else if (this._content.size == LSize.USHORT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.USHORT, Tokens.PLUS);
	    else if (this._content.size == LSize.INT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.INT, Tokens.PLUS);
	    else if (this._content.size == LSize.UINT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.UINT, Tokens.PLUS);
	    else if (this._content.size == LSize.LONG)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.LONG, Tokens.PLUS);
	    else if (this._content.size == LSize.ULONG)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.ULONG, Tokens.PLUS);
	    else if (this._content.size == LSize.FLOAT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.FLOAT, Tokens.PLUS);
	    else if (this._content.size == LSize.DOUBLE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.DOUBLE, Tokens.PLUS);
	    else return null;
	    return ptr;
	}
	return null;
    }

    /**
     Surcharge de l'operateur '-' à droite.
     Params:
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     Bugs: ne marche pas avec les long.
     */
    private InfoType SubRight (Expression left) {
	if (cast (DecimalInfo) left.info.type) {
	    auto ptr = new PtrInfo (this.isConst, this._content.clone ());
	    if (this._content.size == LSize.BYTE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.BYTE, Tokens.MINUS);
	    if (this._content.size == LSize.UBYTE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.UBYTE, Tokens.MINUS);
	    if (this._content.size == LSize.SHORT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.SHORT, Tokens.MINUS);
	    if (this._content.size == LSize.USHORT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.USHORT, Tokens.MINUS);
	    if (this._content.size == LSize.INT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.INT, Tokens.MINUS);
	    if (this._content.size == LSize.UINT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.UINT, Tokens.MINUS);
	    if (this._content.size == LSize.LONG)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.LONG, Tokens.MINUS);
	    if (this._content.size == LSize.ULONG)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.ULONG, Tokens.MINUS);
	    if (this._content.size == LSize.FLOAT)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.FLOAT, Tokens.MINUS);
	    if (this._content.size == LSize.DOUBLE)  ptr.lintInst = &PtrUtils.InstOpInv !(LSize.DOUBLE, Tokens.MINUS);
	    return ptr;
	}
	return null;
    }

    /**
     Surcharge de l'operateur 'is'.
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType Is (Expression right) {
	if (cast (PtrInfo) right.info.type) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &PtrUtils.InstIs;
	    return ret;
	} else if (cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &PtrUtils.InstIsNull;
	    return ret;
	}
	return null;
    }

    /**
     Surcharge de l'operateur '!is';
     Params:
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    private InfoType NotIs (Expression right) {
	if (cast (PtrInfo) right.info.type) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &PtrUtils.InstNotIs;
	    return ret;
	} else if (cast (NullInfo) right.info.type) {
	    auto ret = new BoolInfo (true);
	    ret.lintInst = &PtrUtils.InstNotIsNull;
	    return ret;
	}
	return null;
    }    

    /**
     Surcharge de l'operateur unaire '*'.
     Returns: une instance du type contenu, ou null si le contenu est 'void' ou 'undef'.
     */
    private InfoType Unref () {
	if (cast (UndefInfo) this._content) return null;
	else if (cast (VoidInfo) this._content) return null;
	auto ret = this._content.clone ();
	if (this._content.size == LSize.BYTE)  ret.lintInstS.insertBack(&PtrUtils.InstUnref!(LSize.BYTE));
	else if (this._content.size == LSize.UBYTE)  ret.lintInstS.insertBack(&PtrUtils.InstUnref!(LSize.UBYTE));
	else if (this._content.size == LSize.SHORT)  ret.lintInstS.insertBack (&PtrUtils.InstUnref!(LSize.SHORT));
	else if (this._content.size == LSize.USHORT)  ret.lintInstS.insertBack (&PtrUtils.InstUnref!(LSize.USHORT));
	else if (this._content.size == LSize.INT)  ret.lintInstS.insertBack (&PtrUtils.InstUnref!(LSize.INT));
	else if (this._content.size == LSize.UINT)  ret.lintInstS.insertBack (&PtrUtils.InstUnref!(LSize.UINT));
	else if (this._content.size == LSize.LONG)  ret.lintInstS.insertBack (&PtrUtils.InstUnref!(LSize.LONG));
	else if (this._content.size == LSize.ULONG)  ret.lintInstS.insertBack (&PtrUtils.InstUnref!(LSize.ULONG));
	else if (this._content.size == LSize.FLOAT)  ret.lintInstS.insertBack (&PtrUtils.InstUnref!(LSize.FLOAT));
	else if (this._content.size == LSize.DOUBLE)  ret.lintInstS.insertBack (&PtrUtils.InstUnref!(LSize.DOUBLE));
	else return null;
	ret.isConst = this.isConst;
	return ret;
    }


    private InfoType toPtr () {
	auto other = new PtrInfo (this.isConst);
	other.content = this.clone ();
	other.lintInstS.insertBack (&PtrUtils.InstAddr);
	return other;
    }
    
    /**
     Surcharge de l'operateur d'accés au attribut.
     Params:
     var = l'attribut demandé.
     Returns: le type résultat ou null.
     */
    override InfoType DotOp (Var var) {
	if (var.templates.length != 0) return null;
	if (cast (Type) var || var.isType) {
	    auto type = var.asType ();
	    auto ret = type.info.type;
	    if (ret.size == LSize.BYTE)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.BYTE);
	    else if (ret.size == LSize.UBYTE)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.UBYTE);
	    else if (ret.size == LSize.SHORT)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.SHORT);
	    else if (ret.size == LSize.USHORT)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.USHORT);
	    else if (ret.size == LSize.INT)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.INT);
	    else if (ret.size == LSize.UINT)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.UINT);
	    else if (ret.size == LSize.LONG)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.LONG);
	    else if (ret.size == LSize.ULONG)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.ULONG);
	    else if (ret.size == LSize.FLOAT)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.FLOAT);
	    else if (ret.size == LSize.DOUBLE)  ret.lintInst = &PtrUtils.InstUnrefDot!(LSize.DOUBLE);
	    else return null;
	    ret.isConst = false;
	    return ret;
	} else if (var.token.str == "init") {
	    auto type = this.clone ();
	    type.lintInst = &PtrUtils.InstNull;
	    return type;
	} else if (var.token.str == "typeid") {
	    auto str = new StringInfo (true);
	    str.value = new StringValue (this.typeString);
	    return str;
	}
	return null;  
    }

    /**
     Returns: le type contenu dans le ptr.
     */
    ref InfoType content () {
	return this._content;
    }

    /**
     Returns une nouvelle instance de ptr
     */
    override InfoType clone () {
	auto ret = new PtrInfo (this.isConst);
	if (this._content !is null)
	    ret._content = this._content.clone ();
	return ret;
    }

    override Expression toYmir () {
	Array!Expression templates = make!(Array!Expression) (this._content.toYmir ());
	Word w = Word.eof;
	w.str = "p";
	auto ret = new Var (w, templates);
	ret.info = new Symbol (w, this.clone ());
	return ret;
    }
    
    /**
     Returns: une nouvelle instance de ptr
     */
    override InfoType cloneForParam () {
	return clone ();
    }

    /**
     Surcharge de l'operateur de cast.
     Params:
     other = le type ves lequel on veut caster.
     Returns: le type résultat ou null.
     */
    override InfoType CastOp (InfoType other) {
	auto type = cast (PtrInfo) other;
	if (type && type.content.isSame (this._content)) {
	    return this;
	} else if (type) {
	    auto ptr = new PtrInfo (this.isConst, type.content.clone ());
	    ptr.lintInstS.insertBack (&PtrUtils.InstCast);
	    return ptr;
	} else if (auto tu = cast (TupleInfo) other) {
	    auto ot = tu.cloneForParam ();
	    ot.leftTreatment = &PtrUtils.InstCastTuple;
	    ot.lintInstS.insertBack (&PtrUtils.InstCast);
	    return ot;
	} else if (auto st = cast (StructInfo) other) {
	    auto ot = st.cloneForParam ();
	    ot.lintInstS.insertBack (&PtrUtils.InstCast);
	    return ot;
	} else if (auto ul = cast (DecimalInfo) other) {
	    if (ul.type == DecimalConst.ULONG) {
		auto ot = ul.cloneForParam ();
		ot.lintInstS.insertBack (&PtrUtils.InstCast);
		return ot;
	    }
	}
	return null;
    }

    /**
     Surcharge de l'operateur de cast automatique.
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
     */
    override InfoType CompOp (InfoType other) {
	if (other.isSame (this) || cast (UndefInfo) other) {
	    auto ptr = this.clone ();
	    ptr.lintInst = &PtrUtils.InstAffect;
	    return ptr;
	}	       
	return null;
    }

    /**
     Returns: le nom du type.
     */
    override string innerTypeString () {
	if (this._content is null) {
	    return "ptr!void";
	} else return "ptr!" ~ this._content.innerTypeString ();	
    }

    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	return "P" ~ this._content.simpleTypeString ();
    }
    
    /**
     Returns: la taille mémoire du type.
     */
    override LSize size () {
	return LSize.ULONG;
    }
    
    override InfoType getTemplate (ulong i) {
	if (i == 0) return this._content;
	return null;
    }

}
