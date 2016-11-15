module ast.While;
import ast.Instruction, ast.Expression;
import ast.Block, syntax.Word, semantic.pack.Symbol;
import semantic.types.BoolInfo, semantic.types.InfoType;
import utils.exception;
import std.stdio, std.string;

class While : Instruction {

    private Expression _test;
    private Block _block;
    private InfoType _info;
    
    this (Word word, Expression test, Block block) {
	super (word);
	this._test = test;
	this._block = block;
    }

    override Instruction instruction () {
	auto expr = this._test.expression;
	auto type = expr.info.type.CastOp (new BoolInfo ());
	auto word = this._token;
	word.str = "cast";
	if (type is null) throw new UndefinedOp (word, expr.info, new Symbol (word, new BoolInfo ()));
	auto bl = this._block.block;
	auto _while = new While (this._token, expr, bl);
	_while._info = type;
	return _while;
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
    
    override void print (int nb = 0) {
	writefln ("%s<While> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	
	this._test.print (nb + 4);
	this._block.print (nb + 4);
    }
    
}
