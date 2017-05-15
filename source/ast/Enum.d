module ast.Enum;
import ast.Declaration;
import syntax.Word, utils.exception;
import ast.Var, ast.Block;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
import std.container, std.stdio, std.string;
import semantic.types.StructInfo, semantic.types.InfoType;
import ast.Expression;
import semantic.types.EnumInfo;

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
    
    override void declareAsExtern () {
	if (this._isPublic) 
	    declare ();
    }

    override void declare () {
	auto exist = Table.instance.get (this._ident.str);
	if (exist) {
	    throw new ShadowingVar (this._ident, exist.sym);
	} else {
	    if (this._type !is null) {
		auto type = this._type.asType ();
		auto en = new EnumCstInfo (this._ident.str, type.info.type);
		auto sym = new Symbol (this._ident, en);
		Table.instance.insert (sym);
		foreach (it; 0 .. this._names.length) {
		    auto val = this._values [it].expression;
		    auto comp = val.info.type.CompOp (type.info.type);
		    if (comp !is null)
			en.addAttrib (this._names [it].str, val, comp);
		    else throw new IncompatibleTypes (type.info,
						      val.info);
		}
	    } else {
		auto en = new EnumCstInfo (this._ident.str);
		auto sym = new Symbol (this._ident, en);
		Table.instance.insert (sym);
		foreach (it; 0 .. this._names.length) {
		    auto val = this._values [it].expression;
		    en.addAttrib (this._names [it].str, val);
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
