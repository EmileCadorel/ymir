module ast.Match;
import ast.Expression, ast.Block;
import ast.Instruction;
import std.container;
import ast.Binary, semantic.pack.Table;
import utils.exception;
import syntax.Word, semantic.types.InfoType;

class Match : Expression {

    private Expression _expr;
    
    private Array!Expression _values;

    private Array!Block _blocks;
    
    private Block _default;

    private Array!Expression _results;
    
    private Expression _defaultResult;

    private Array!InfoType _cstrs;
    
    this (Word word, Expression expr, Array!Expression values, Array!Block blocks, Block def) {
	super (word);
	this._expr = expr;
	this._values = values;
	this._blocks = blocks;
	this._default = def;
    }

    override Instruction instruction () {
	auto expr = this._expr.expression;
	Array!Expression values;
	Array!Block blocks;
	auto eq = Word (this._token.locus, Tokens.DEQUAL.descr, true);
	foreach (it ; 0 .. this._values.length) {
	    auto current = this._values [it];
	    try {
		auto bin = new Binary (eq, expr, current);
		values.insertBack (bin.expression);		
		blocks.insertBack (this._blocks [it].block);		
	    } catch (UndefinedOp) {
	    }
	}
	
	Block def;
	if (this._default) {
	    def = this._default.block ();
	}
	
	return new Match (this._token, expr, values, blocks, def);	
    }
    
    override Expression expression () {
	auto expr = this._expr.expression ();
	Array!Expression values;
	Array!Expression results;
	Array!InfoType cstrs;
	Symbol info;
	auto eq = Word (this._token.locus, Tokens.DEQUAL.descr, true);
	foreach (it ; 0 .. this._values.length) {
	    auto current = this._values [it];
	    try {
		auto bin = new Binary (eq, expr, current);
		values.insertBack (bin.expression);
		auto insts = this._blocks [it].insts ();
		if (insts.length != 1 || !cast (Expression) insts[0]) {
		    throw new NoValueMatch (this._blocks [it].token);
		} else {
		    Table.instance.pacifyMode ();
		    scope (exit) Table.instance.unpacifyMode ();
		    results.insertBack ((cast (Expression) insts [0]).expression);
		    if (info is null) {
			info = results.back ().info;
			cstrs.insertBack (info.type);
		    } else {
			auto type = info.type.CompOp (results.back ().info.type);
			if (type !is null) cstrs.insertBack (type);
			else throw new IncompatibleTypes (info, results.back ().info);
		    }
		}
	    } catch (UndefinedOp) {
	    }	       
	}

	Expression def;
	if (this._default) {
	    auto insts = this._default.insts;
	    if (insts.length != 1 || !cast (Expression) insts [0])
		throw new NoValueMatch (this._default.token);

	    Table.instance.pacifyMode ();
	    scope (exit) Table.instance.unpacifyMode ();
	    def = (cast (Expression) insts [0]).expression;
	    if (info is null) {
		info = def.info;
		cstrs.insertBack (info.type);
	    } else {
		auto type = info.type.CompOp (def.info.type);
		if (type !is null) cstrs.insertBack (type);
		else throw new IncompatibleTypes (info, def.info);
	    }
	} else throw new NotDefaultMatch (this._token);
	
	auto match = new Match (this._token, expr, values, make!(Array!Block), this._default);
	match._results = results;
	match._defaultResult = def;
	match._cstrs = cstrs;
	match.info = new Symbol (this._token, info.type.clone ());
	match.info.value = null;
	return match;
    }

    override Expression templateExpReplace (Expression [string] values) {
	auto expr = this._expr.templateExpReplace (values);
	Array!Expression auxValues;
	Array!Block auxBlock;
	foreach (it ; this._values) {
	    auxValues.insertBack (it.templateExpReplace (values));
	}

	foreach (it ; this._blocks) {
	    auxBlock.insertBack (it.templateReplace (values));
	}
	if (this._default)	
	    return new Match (this._token, expr, auxValues, auxBlock, this._default.templateReplace (values));
	else
	    return new Match (this._token, expr, auxValues, auxBlock, null);
    }

    override Expression clone () {
	auto expr = this._expr.clone;
	Array!Expression auxValues;
	Array!Block auxBlock;
	foreach (it ; this._values) {
	    auxValues.insertBack (it.clone);
	}

	foreach (it ; this._blocks) {
	    auxBlock.insertBack (it.templateReplace (null));
	}
	if (this._default)
	    return new Match (this._token, expr, auxValues, auxBlock, this._default.templateReplace (null));
	else
	    return new Match (this._token, expr, auxValues, auxBlock, null);
    }

    Expression expr () {
	return this._expr;
    }
    
    Array!Expression values () {
	return this._values;
    }

    Array!Block blocks () {
	return this._blocks;
    }

    Array!Expression results () {
	return this._results;
    }

    Array!InfoType cstr () {
	return this._cstrs;
    }
    
    Block defaultBlock () {
	return this._default;
    }    

    Expression defaultResult () {
	return this._defaultResult;
    }
    
    override string prettyPrint () {
	import std.outbuffer;
	auto buf = new OutBuffer ();
	buf.writefln ("match %s {", this._expr.prettyPrint);
	foreach (it ; this._values)
	    buf.writefln ("\t%s => {...}", it.prettyPrint);
	buf.writefln ("}");
	return buf.toString;
    }
    
}
