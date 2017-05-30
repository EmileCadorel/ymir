module ast.TupleDest;
import ast.Instruction, ast.Var, ast.Expression;
import std.container, syntax.Word, utils.YmirException;
import semantic.pack.Table, semantic.pack.Symbol;
import std.stdio, std.string, std.outbuffer;
import semantic.types.UndefInfo, utils.exception;
import ast.Binary, ast.Expand;
import semantic.types.TupleInfo;
import syntax.Tokens;

class TupleDest : Instruction {

    /++ la liste des variable déclaré dans le destructeur de tuple +/
    private Array!Var _decls;

    /++
     La liste d'instruction à effectuer
     +/
    private Array!Expression _insts;
    
    /++ L'expression droite de l'instruction +/
    private Expression _right;

    /++ Le destructeur est déclarer en temps que variadic ? -> '...' +/
    bool _isVariadic = false;
    

    this (Word token, bool isVariadic, Array!Var decls, Expression right) {
	super (token);
	this._isVariadic = isVariadic;
	this._decls  = decls;
	this._right = right;
    }

    this (Word token, Array!Expression insts, Expression right) {
	super (token);
	this._insts = insts;
	this._right = right;
    }
    
    override Instruction instruction () {
	auto right = this._right.expression ();
	if (!cast (TupleInfo) right.info.type) throw new DestOfNonTuple (right.info);
	auto tupleType = cast (TupleInfo) right.info.type;
	auto aff = Word (this._token.locus, Tokens.EQUAL.descr, true);
	Array!Expression insts;
	if (!this._isVariadic) {	    
	    if (this._decls.length != tupleType.params.length)
		throw new DestOfNonTuple (this._decls.length, tupleType.params.length, right.info);

	    ulong i = 0;
	    foreach (it ; this._decls []) {
		auto aux = new Var (it.token);
		auto info = Table.instance.get (it.token.str);		
		if (info !is null && Table.instance.sameFrame (info)) throw new ShadowingVar (it.token, info.sym);
		aux.info = new Symbol (aux.token, new UndefInfo (), false);
		Table.instance.insert (aux.info);
		auto exp = new Expand (right.token, right, i);
		exp.info = new Symbol (false, exp.token, tupleType.params [i].clone);
		
		insts.insertBack (new Binary (aff, new Var (it.token), exp).expression);
		i ++;
	    }
	    
	    return new TupleDest (this._token, insts, right);
	} else
	    assert (false, "TODO");
    }

    Expression expr () {
	return this._right;
    }
    
    Array!Expression insts () {
	return this._insts;
    }
    
    override Instruction templateReplace (Expression [string] values) {
	auto decls = this._decls.dup ();
	auto right = this._right.templateExpReplace (values);
	return new TupleDest (this._token, this._isVariadic, decls, right);
    }
    

}
