module ast.Mixin;
import ast.Expression;
import std.stdio, syntax.Tokens;
import syntax.Word, utils.exception;
import semantic.pack.Symbol;
import ast.Instruction;
import syntax.Visitor, syntax.Lexer;
import semantic.types.StringInfo;
import semantic.value.StringValue;
import std.format, semantic.pack.Table;
import std.container;

class Mixin : Expression {

    /** l'expression que l'on va mixin */
    private Expression _inside;
    
    
    this (Word ident, Expression inside) {
	super (ident);
	this._inside = inside;
    }

    /**
       Returns: un Block, lu dans la chaine (il est verifié sémantiquement)
       Throws: IncompatibleTypes, SyntaxError
     */
    override Instruction instruction () {
	import syntax.SyntaxError;
	auto msg = this._inside.expression ();
	if (!msg.info.type.isSame (new StringInfo))
	    throw new IncompatibleTypes (msg.info, new StringInfo);

	if (msg.info.value is null)
	    throw new NotImmutable (msg.info);
	
	Table.instance.removeGarbage (msg.info);	
	auto visit = new Visitor ();
	visit.lexer = new StringLexer ("{" ~ (cast(StringValue) msg.info.value).value ~ "}",
				       [Tokens.SPACE, Tokens.RETOUR, Tokens.RRETOUR, Tokens.TAB],
				       [[Tokens.LCOMM1, Tokens.RCOMM1],
					[Tokens.LCOMM2, Tokens.RETOUR],
					[Tokens.LCOMM3, Tokens.RCOMM3]]);
	try {
	    auto bl = visit.visitBlockOutSide ();
	    return bl.block ();
	} catch (SyntaxError err) {
	    throw new SyntaxError (err.msg, (cast(StringValue) msg.info.value).value);
	}
    }

    /**
       Returns: une expression lu dans la chaine (elle est verifiée sémantiquement)
       Throws: IncompatibleTypes, SyntaxError, NotImmutable
     */
    override Expression expression () {
	import syntax.SyntaxError;
	auto msg = this._inside.expression ();
	if (!msg.info.type.isSame (new StringInfo))
	    throw new IncompatibleTypes (msg.info, new StringInfo);

	if (msg.info.value is null)
	    throw new NotImmutable (msg.info);
	
	Table.instance.removeGarbage (msg.info);	
	auto visit = new Visitor ();
	visit.lexer = new StringLexer ((cast(StringValue) msg.info.value).value,
				       [Tokens.SPACE, Tokens.RETOUR, Tokens.RRETOUR, Tokens.TAB],
				       [[Tokens.LCOMM1, Tokens.RCOMM1],
					[Tokens.LCOMM2, Tokens.RETOUR],
					[Tokens.LCOMM3, Tokens.RCOMM3]]);
	try {
	    auto expr = visit.visitExpressionOutSide ();
	    return expr.expression ();
	} catch (SyntaxError err) {
	    throw new SyntaxError (err.msg, (cast(StringValue) msg.info.value).value);
	}
    }    

    override Expression templateExpReplace (Array!Expression names, Array!Expression values) {
	auto inside = this._inside.templateExpReplace (names, values);
	return new Mixin (this._token, inside);
    }
    
    override string prettyPrint () {
	return format ("mixin (%s)", this._inside.prettyPrint);
    }
    
}
