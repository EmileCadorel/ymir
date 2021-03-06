module ymir.ast.Enum;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container, std.stdio, std.string;

class Enum : Declaration {
    
    private Word _ident;
    private Var _type;
    private Array!Word _names;
    private Array!Expression _values;

    this (Word ident, Var type, Array!Word names, Array!Expression values) {
	this._ident = ident;
	this._type = type;
	this._names = names;
	this._values = values;
	this._isPublic = true;
    }

    /**
     Returns: les paramètre de l'enum
     */
    Array!Word names () {
	return this._names;
    }

    /**
     Returns: les valeurs de l'enum
     */
    Array!Expression values () {	
	return this._values;
    }

    /**
     Returns: l'identifiant de l'enum (peut être eof)
     */
    Word ident () const {
	return this._ident;
    }
    
    override void declareAsExtern (Module mod) {
	auto exist = mod.get (this._ident.str);
	if (exist) {
	    throw new ShadowingVar (this._ident, exist.sym);
	} else {
	    Symbol type; Expression fst;	    
	    if (this._type !is null) {
		type = this._type.asType ().info;	    
	    } else {
		fst = this._values [0].expression;
		type = fst.info;
	    }
	    
	    auto en = new EnumCstInfo (this._ident.str, type.type);
	    auto sym = new Symbol (this._ident, en);
	    sym.isPublic = this._isPublic;		
	    mod.insert (sym);
	    
	    foreach (it; 0 .. this._names.length) {
		if (it == 0 && fst)
		    en.addAttrib (this._names [it].str, fst, null);
		else {
		    auto val = this._values [it].expression;
		    auto comp = val.info.type.CompOp (type.type);
		    if (comp !is null)
		    en.addAttrib (this._names [it].str, val, comp);
		    else throw new IncompatibleTypes (type,
						      val.info);
		}
	    }
	}
    }

    override void declare () {
	auto exist = Table.instance.getLocal (this._ident.str);
	if (exist) {
	    throw new ShadowingVar (this._ident, exist.sym);
	} else {
	    Symbol type; Expression fst;	    
	    if (this._type !is null) {
		type = this._type.asType ().info;	    
	    } else {
		fst = this._values [0].expression;
		type = fst.info;
	    }
	    
	    auto en = new EnumCstInfo (this._ident.str, type.type);
	    auto sym = new Symbol (this._ident, en);
	    sym.isPublic = true;		
	    Table.instance.insert (sym);	    
	    
	    foreach (it; 0 .. this._names.length) {
		if (it == 0 && fst)
		    en.addAttrib (this._names [it].str, fst, null);
		else {
		    auto val = this._values [it].expression;
		    auto comp = val.info.type.CompOp (type.type);
		    if (comp !is null)
		    en.addAttrib (this._names [it].str, val, comp);
		    else throw new IncompatibleTypes (type,
						      val.info);
		}
	    }
	}
    }

    override Declaration templateReplace (Expression [string] values) {
	auto type = cast (Var) this._type.templateExpReplace (values);
	Array!Expression values_;
	foreach (it ; this._values) {
	    values_.insertBack (it.templateExpReplace (values));
	}
	
	return new Enum (this._ident, type, this._names, values_);
    }    
       
}
