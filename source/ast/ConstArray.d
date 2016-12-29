module ast.ConstArray;
import ast.Expression;
import std.container;
import semantic.types.InfoType;
import semantic.pack.Symbol;
import semantic.types.ArrayInfo;
import syntax.Word;
import semantic.types.VoidInfo, semantic.types.UndefInfo;
import ast.Var;
import utils.exception;
import std.stdio, std.string;

class ConstArray : Expression  {

    private Array!Expression _params;
    private Array!InfoType _casters;
    
    this (Word token, Array!Expression params) {
	super (token);
	this._params = params;
    }

    Array!Expression params () {
	return this._params;
    }

    Array!InfoType casters () {
	return this._casters;
    }
    
    override Expression expression () {
	auto aux = new ConstArray (this._token, this._params);
	if (aux._params.length == 0) {
	    aux.info = new Symbol (aux._token, new ArrayInfo (new VoidInfo), true);
	} else {
	    InfoType last = null;
	    foreach (ref it ; aux._params) {
		it = it.expression;
	    }

	    if (aux._params.length == 1) {
		auto type = cast (Type) aux._params [0];
		if (type) {
		    auto tok = Word (this.token.locus,
				     this.token.str,
				     false);
		    tok.str = this.token.str ~ type.token.str ~ "]";
		    return new Type (tok, new ArrayInfo (type.info.type));
		}
	    }
	    
	    auto begin = new Symbol(false, this._token, new UndefInfo ());
	    foreach (fst ; 0 .. aux._params.length) {		
		auto cmp = aux._params [fst].info.type.CompOp (begin.type);
		aux._casters.insertBack (cmp);
		if (cmp is null) {
		    throw new IncompatibleTypes (begin,
						 aux._params [fst].info);
		}
		begin.type = cmp;
	    }
	    aux._info = new Symbol (aux._token, new ArrayInfo (begin.type.clone ()), true);
	}
	return aux;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Array> %s(%d, %d) ",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	foreach (it ; this._params) {
	    it.print (nb + 4);
	}
    }
    

}