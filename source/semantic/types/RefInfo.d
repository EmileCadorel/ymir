module semantic.types.RefInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.RefUtils, syntax.Keys;
import semantic.types.BoolInfo;
import semantic.types.UndefInfo, lint.LSize;
import ast.ParamList, semantic.types.StructInfo;
import std.container;

/**
 Classe contenant les informations de type d'une référence.
 */
class RefInfo : InfoType {

    /** Le type contenu dans la référence */
    private InfoType _content = null;
    
    this () {
	this._content = new VoidInfo ();
    }

    /**
     Params:
     content = le type contenu dans la référence.
     */
    this (InfoType content) {
	this._content = content;
    }

    /**
     Returns: le type contenu dans la référence.
     */
    InfoType content () {
	return this._content;
    }

    /**
     Params:
     other = le deuxieme type.
     Returns: les types sont identiques ?
     */
    override bool isSame (InfoType other) {
	auto ptr = cast (RefInfo) other;
	if (ptr is null) return false;
	if (this._content is ptr.content) return true;
	return ptr.content.isSame (this._content);
    }

    /**
     Créé une instance de type ref en fonction de paramètre template.
     Params:
     token = l'identificateur du créateur.
     templates = les paramètres templates du type.
     Returns: Une instance de ref.
     Throws: UndefinedType.
     */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 1 || !(cast (Type) templates [0]))
	    if (auto _cst = cast (StructCstInfo) templates [0].info.type) {
		return new RefInfo (_cst.create (templates [0].token, []));
	    } else
		throw new UndefinedType (token, "prend un type en template");
	else return new RefInfo (templates [0].info.type);	
    }
    
    /**
     Surcharge des operateurs binaire.
     Params:
     token = l'operateur.
     right = l'operande droite de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOp (Word token, Expression right) {
	InfoType aux;
	InfoType refRight = null;
	if (auto type = cast (RefInfo) right.info.type) {
	    aux = this._content.BinaryOp (token, type.content);
	    refRight = type.content;
	} else aux = this._content.BinaryOp (token, right);	
	if (aux !is null) {
	    aux = addUnref (aux);
	    if (refRight) aux = addUnrefRight (aux);
	    return aux;
	}	
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
	auto aux = this._content.BinaryOpRight (token, left);	
	if (aux !is null) {
	    return addUnref (aux);
	} else {
	    return addUnrefRight (left.info.type.BinaryOp (token, this._content));
	}
    }

    /**
     Surcharge des operateurs d'acces.
     Params:
     token = l'operateur.
     params = les operandes droite de l'expression.
     Returns: le type résultat ou null.
    */
    override InfoType AccessOp (Word token, ParamList params) {
	return addUnref (this._content.AccessOp (token, params));
    }

    /**
     Surcharge des operateurs d'acces aux attributs.
     Params:
     var = l'attribut demandé.
     Returns: le type résultat ou null.
    */
    override InfoType DotOp (Var var) {	
	return addUnref (this._content.DotOp (var));
    }

    override InfoType DotExpOp (Expression elem) {
	return addUnref (this._content.DotExpOp (elem));
    }

    override InfoType DColonOp (Var var) {
	return addUnref (this._content.DColonOp (var));
    }
    
    
    /**
     Surcharge de l'operateur unaire.
     Params:
     op = l'operateur.
     Returns: le type résultat ou null.
     */
    override InfoType UnaryOp (Word op) {
	return addUnref (this._content.UnaryOp (op));
    }

    /**
     Returns: une nouvelle instance de ref.
     */
    override InfoType clone () {
	return new RefInfo (this._content.clone ());
    }

    /**
     Returns: une nouvelle instance de ref.
    */
    override InfoType cloneForParam () {	
	return new RefInfo (this._content.cloneForParam ());
    }

    override InfoType CastOp (InfoType other) {
	auto ptr = cast (RefInfo) other;
	if (ptr && ptr.content.isSame (this._content)) {
	    auto rf = this.clone ();
	    rf.lintInst = &RefUtils.InstAffect;
	    return rf;
	} else {
	    return addUnref (this._content.CastOp (other));	    
	}
    }
       
    /**
     Surcharge de l'operateur de cast automatique.
     Params:
     other = le type vers lequel on veut caster.
     Returns: le type résultat ou null.
    */
    override InfoType CompOp (InfoType other) {
	auto ptr = cast (RefInfo) other;
	if (cast (UndefInfo) other || (ptr && ptr.content.isSame (this._content))) {
	    auto rf = this.clone ();
	    rf.lintInst = &RefUtils.InstAffect;
	    return rf;
	} else {
	    return addUnref (this._content.CompOp (other));
	}
    }


    override InfoType ApplyOp (Array!Var vars) {
	return addUnref (this._content.ApplyOp (vars));
    }

    override ApplicationScore CallOp (Word op, ParamList params)  {
	auto ret = this._content.CallOp (op, params);
	if (ret && ret.dyn) {
	    ret.left = addUnref (this._content.cloneForParam ());	    
	}
	return ret;
    }

    
    
    private InfoType addUnref (InfoType aux) {
	if (aux !is null) {
	    if (this._content.size == LSize.BYTE)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.BYTE));
	    else if (this._content.size == LSize.UBYTE)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.UBYTE));
	    else if (this._content.size == LSize.SHORT)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.SHORT));
	    else if (this._content.size == LSize.USHORT)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.USHORT));
	    else if (this._content.size == LSize.INT)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.INT));
	    else if (this._content.size == LSize.UINT)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.UINT));
	    else if (this._content.size == LSize.LONG)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.LONG));
	    else if (this._content.size == LSize.ULONG)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.ULONG));
	    else if (this._content.size == LSize.FLOAT)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.FLOAT));
	    else if (this._content.size == LSize.DOUBLE)  aux.lintInstS.insertBack (&RefUtils.InstUnrefS!(LSize.DOUBLE));
	}
	return aux;
    }

    private InfoType addUnrefRight (InfoType aux) {
	if (aux) {
	    if (this._content.size == LSize.BYTE)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.BYTE));
	    else if (this._content.size == LSize.UBYTE)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.BYTE));
	    else if (this._content.size == LSize.SHORT)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.SHORT));
	    else if (this._content.size == LSize.USHORT)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.USHORT));
	    else if (this._content.size == LSize.INT)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.INT));
	    else if (this._content.size == LSize.UINT)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.UINT));
	    else if (this._content.size == LSize.LONG)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.LONG));
	    else if (this._content.size == LSize.ULONG)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.ULONG));
	    else if (this._content.size == LSize.FLOAT)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.FLOAT));
	    else if (this._content.size == LSize.DOUBLE)  aux.lintInstSR.insertBack (&RefUtils.InstUnrefS!(LSize.DOUBLE));
	}
	return aux;	    
    }

    
    /**
     Returns: le nom du type.
     */
    override string typeString () {
	return "ref(" ~ this._content.typeString () ~ ")";
    }

    /**
     Returns: le nom simple du type.
     */
    override string simpleTypeString () {
	return "R" ~ this.content.simpleTypeString ();	
    }
    
    /**
     Returns: le type est constant ?
     */
    override ref bool isConst () {
	return this._content.isConst;
    }

    /**

    /**
     Returns: la taille mémoire du type ref.
     */
    override LSize size () {
	return LSize.LONG;
    }   
    
    override InfoType getTemplate (ulong i) {
	if (i == 0) return this._content;
	return null;
    }

}
