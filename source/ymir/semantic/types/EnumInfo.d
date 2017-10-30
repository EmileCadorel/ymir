module ymir.semantic.types.EnumInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container, std.outbuffer, std.format;

class EnumCstInfo : InfoType {

    /** Le nom de l'enum */
    private string _name;

    /** le type de l'enum (peut etre null) */
    private InfoType _type;
    
    /** Les informations de compatibilité */
    private Array!InfoType _comps;

    /** Les nom des paramètre de l'enum */
    private Array!string _names;

    /** Les valeurs de l'enum */
    private Array!Expression _values;

    this (string name, InfoType type) {
	super (true);
	this._name = name;
	this._type = type;
    }

    string name () {
	return this._name;
    }
    
    ref Array!Expression values () {
	return this._values;
    }
    
    ref Array!InfoType comps () {
	return this._comps;
    }

    ref InfoType type () {
	return this._type;
    }
    
    /**
     Ajoute une valeur à l'enum
     */
    void addAttrib (string name, Expression value, InfoType comp = null) {
	this._names.insertBack (name);
	this._values.insertBack (value);
	this._comps.insertBack (comp);
    }

    override InfoType DColonOp (Var elem) {
	ulong i = 0;
	if (elem.templates.length != 0) return null;
	foreach (it ; this._names) {
	    if (it == elem.token.str) {
		return GetAttrib (i);
	    }
	    i++;
	}
	return null;
    }
       
    override InfoType DotOp (Var var) {
	if (var.token.str == "members") {
	    auto info = new ArrayInfo (true, new EnumInfo (true, this._name, this._type.clone ()));
	    info.lintInst = &EnumUtils.Members;
	    info.leftTreatment = &EnumUtils.GetMembers;
	    return info;
	} else return null;
    }
    
    InfoType create () {
	return new EnumInfo (false, this._name, this._type.cloneForParam ());
    }
    
    private InfoType GetAttrib (ulong nb) {
	auto type = new EnumInfo (true, this._name, this._type.clone ());
	if (this._values [nb].info.value) {
	    type._content.value = this._values [nb].info.value;
	}
	type.toGet = nb;
	type.lintInst = &EnumUtils.Attrib;
	type.leftTreatment = &EnumUtils.GetAttribComp;
	return type;	    
    }
    
    override string simpleTypeString () {
	return format ("%d%s%s)", this._name.length, "E", this._name);
    }

    override string innerTypeString () {
	if (this._type !is null)
	    return format ("%s(%s)", this._name, this._type.innerTypeString ());
	else
	    return format ("%s(...)", this._name);
    }
    
    override bool isSame (InfoType other) {
	if (auto en = cast (EnumCstInfo) other) {
	    return en._name == this._name;
	}
	return false;
    }
    
    override InfoType clone () {
	return this;
    }


    override Expression toYmir () {
	auto w = Word.eof;
	w.str = this._name;
	return new Type (w, this.clone ());	
    }

    
    override InfoType cloneForParam () {
	assert (false, "Pas ici");
    }

    override bool isScopable () {
	return true;
    }
    
}


class EnumInfo : InfoType {

    private string _name;
    private InfoType _content;

    this (bool isConst, string name, InfoType content) {
	super (isConst);
	this._name = name;
	this._content = content;
	this._content.isConst = this.isConst;
    }

    string name () {
	return this._name;
    }    
    
    override InfoType BinaryOp (Word token, Expression right) {
	InfoType aux;
	if (auto type = cast (EnumInfo) right.info.type) {
	    aux = this._content.BinaryOp (token, type._content);
	} else aux = this._content.BinaryOp (token, right);
	return aux;
    }

    override InfoType BinaryOpRight (Word token, Expression left) {
	if (cast (UndefInfo) left.info.type)
	    return this._content.BinaryOpRight (token, left);
	else
	    return left.info.type.BinaryOp (token, this._content);
    }

    override InfoType AccessOp (Word token, ParamList params) {
	return this._content.AccessOp (token, params);
    }

    override InfoType DotOp (Var var) {
	if (var.token.str == "typeid") {
	    auto str = new StringInfo (true);
	    str.value = new StringValue (this.typeString);
	    return str;
	}
	return this._content.DotOp (var);	
    }

    override InfoType DotExpOp (Expression var) {
	return this._content.DotExpOp (var);
    }
    
    override InfoType DColonOp (Var var) {
	return this._content.DColonOp (var);
    }       

    override InfoType UnaryOp (Word op) {
	return this._content.UnaryOp (op);
    }
    
    override InfoType CastOp (InfoType other) {
	return this._content.CastOp (other);
    }
    
    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || this.isSame (other)) {
	    auto rf = this.clone ();
	    auto ret = this._content.CompOp (this._content);	    
	    rf.lintInst = ret.lintInst;
	    return rf;
	} else {
	    return this._content.CompOp (other);
	}	
    }

    override InfoType ApplyOp (Array!Var vars) {
	return this._content.ApplyOp (vars);
    }    

    override string simpleTypeString () {
	return format ("%d%s%s", this._name.length, "E", this._name);
    }

    override string innerTypeString () {
	return format ("%s(%s)", this._name, this._content.innerTypeString ());
    }
    
    override bool isSame (InfoType other) {
	if (auto en = cast (EnumInfo) other) {
	    if (en._name == this._name
		&& this._content.isSame (en._content)) return true;
	}
	return false;
    }

    override InfoType clone () {
	auto ret = new EnumInfo (this.isConst, this._name, this._content.clone ());
	return ret;
    }

    override Expression toYmir () {
	auto w = Word.eof;
	w.str = this._name;
	return new Type (w, this.clone ());	
    }
    
    override InfoType cloneForParam () {
	return new EnumInfo (this.isConst, this._name, this._content.cloneForParam ());
    }

    override LSize size () {
	return this._content.size;
    }
    
    InfoType content () {
	return this._content;
    }

}
