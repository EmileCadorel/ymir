module ast.If;
import ast.Instruction, utils.exception;
import ast.Expression, ast.Block;
import syntax.Word, std.stdio, std.string;
import semantic.types.BoolInfo, semantic.pack.Symbol, semantic.types.InfoType;

class If : Instruction {

    private Expression _test;
    private Block _block;
    private Else _else;
    private InfoType _info;
    
    this (Word word, Expression test, Block block) {
	super (word);
	this._test = test;
	this._block = block;
    }

    this (Word word, Expression test, Block block, Else else_) {
	super (word);
	this._test = test;
	this._block = block;
	this._else = else_;
    }

    override Instruction instruction () {
	auto expr = this._test.expression;
	auto type = expr.info.type.CastOp (new BoolInfo ());
	auto word = this._token;
	word.str = "cast";
	if (type is null)
	    throw new UndefinedOp (word, expr.info, new Symbol (word, new BoolInfo ()));
	auto bl = this._block.instructions ();
	If _if;
	if (this._else !is null) {
	    _if = new If (this._token, expr, bl, cast(Else) this._else.instruction ());
	    _if._info = type;
	} else {
	    _if = new If (this._token, expr, bl);
	    _if._info = type;
	}
	return _if;
    }

    Expression test () {
	return this._test;
    }
    
    InfoType info () {
	return this._info;
    }

    Block block () {
	return this._block;
    }

    Else else_ () {
	return this._else;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<If> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._test.print (nb + 4);
	this._block.print (nb + 4);
	if (this._else !is null)
	    this._else.print (nb);
    }


}

class Else : Instruction {
    private Block _block;

    this (Word word, Block block) {
	super (word);
	this._block = block;
    }

    override Instruction instruction () {
	return new Else (this._token, this._block.instructions);
    }
    
    Block block () {
	return this._block;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Else> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._block.print (nb + 4);	
    }
    
}

class ElseIf : Else {

    private Expression _test;
    private Else _else;
    private InfoType _info;
    
    this (Word word, Expression test, Block block) {
	super (word, block);
	this._test = test;
    }

    this (Word word, Expression test, Block block, Else else_) {
	super (word, block);
	this._test = test;
	this._else = else_;
    }
    
    override Instruction instruction () {
	auto expr = this._test.expression;
	auto type = expr.info.type.CastOp (new BoolInfo ());
	auto word = this._token;
	word.str = "cast";
	if (type is null)
	    throw new UndefinedOp (word, expr.info, new Symbol (word, new BoolInfo ()));
	auto bl = this._block.instructions ();
	ElseIf _if;
	if (this._else !is null) {
	    _if = new ElseIf (this._token, expr, bl, cast(Else) this._else.instruction ());
	    _if._info = type;
	} else {
	    _if = new ElseIf (this._token, expr, bl);
	    _if._info = type;
	}
	return _if;
    }
    
    Expression test () {
	return this._test;
    }

    Else else_ () {
	return this._else;
    }
    
    InfoType info () {
	return this._info;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<ElseIf> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._test.print (nb + 4);
	this._block.print (nb + 4);
	if (this._else !is null)
	    this._else.print (nb);
    }
    
}
