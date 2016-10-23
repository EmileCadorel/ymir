module syntax.Visitor;
import syntax.Lexer;
import syntax.Word, syntax.Keys;
import syntax.Tokens, syntax.SyntaxError;
import std.stdio, std.outbuffer;
import ast.all, std.container;
import std.algorithm;

class Visitor {


    private Lexer _lex;
    private Token[] _ultimeOp;
    private Token[] _expOp;
    private Token[] _ulowOp;
    private Token[] _lowOp;
    private Token[] _highOp;
    private Token[] _befUnary;
    private Token[] _afUnary;
    private Token[] _suiteElem;
    private Token[] _forbiddenIds;
    
    this (string file) {
	this._lex = new Lexer (file,
			       [Tokens.SPACE, Tokens.RETOUR, Tokens.RRETOUR, Tokens.TAB],
			      [[Tokens.LCOMM1, Tokens.RCOMM1],
			       [Tokens.LCOMM2, Tokens.RETOUR]]);
	this._ultimeOp = [Tokens.DIV_AFF, Tokens.AND_AFF, Tokens.PIPE_EQUAL,
			  Tokens.MINUS_AFF, Tokens.PLUS_AFF, Tokens.LEFTD_AFF,
			  Tokens.RIGHTD_AFF, Tokens.EQUAL, Tokens.STAR_EQUAL,
			  Tokens.PERCENT_EQUAL, Tokens.XOR_EQUAL,
			  Tokens.DXOR_EQUAL, Tokens.TILDE_EQUAL];

	this._expOp = [Tokens.DPIPE, Tokens.DAND];
	this._ulowOp = [Tokens.INF, Tokens.SUP, Tokens.INF_EQUAL,
			Tokens.SUP_EQUAL, Tokens.NOT_EQUAL, Tokens.NOT_INF,
			Tokens.NOT_INF_EQUAL, Tokens.NOT_SUP,
			Tokens.NOT_SUP_EQUAL, Tokens.DEQUAL];
	this._lowOp = [Tokens.PLUS, Tokens.PIPE, Tokens.LEFTD,
		       Tokens.XOR, Tokens.TILDE, Tokens.MINUS,
		       Tokens.RIGHTD];

	this._highOp = [Tokens.DIV, Tokens.DDOT, Tokens.TDOT,
			Tokens.AND, Tokens.STAR, Tokens.PERCENT,
			Tokens.DXOR, Tokens.IMPLIQUE];
	
	this._suiteElem = [Tokens.LPAR, Tokens.LCRO, Tokens.DOT];
	this._afUnary = [Tokens.DPLUS, Tokens.DMINUS];	
	this._befUnary = [Tokens.MINUS, Tokens.AND, Tokens.STAR, Tokens.NOT];
	this._forbiddenIds = [Keys.IMPORT, Keys.CLASS, Keys.STRUCT,
			      Keys.DEF, Keys.NEW, Keys.DELETE, Keys.IF, Keys.RETURN,
			      Keys.FOR, Keys.FOREACH, Keys.WHILE, Keys.BREAK, Keys.THROW,
			      Keys.TRY, Keys.SWITCH, Keys.DEFAULT, Keys.IN, Keys.ELSE,
			      Keys.CATCH, Keys.TRUE, Keys.FALSE, Keys.NULL, Keys.CAST,
			      Keys.FUNCTION, Keys.LET, Keys.IS];
    }

    /**
     program := function | import | struct | class;
     */
    Program visit () {
	Word word = this._lex.next ();
	Array!Declaration decls;
	while (!word.isEof ()) {
	    if (word == Keys.DEF) decls.insertBack (this.visitFunction ());
	    else if (word == Keys.IMPORT) decls.insertBack (this.visitImport ());
	    else throw new SyntaxError (word);
	    _lex.next (word);
	}
	return new Program (decls);
    }

    /**
     import := 'import' (Identifiant ('.' Identifiant)*) (',' Identifiant ('.' Identifiant))* ';'
     */
    private Import visitImport () {
	return null;
    }

    /**
     function := 'def' Identifiant '(' (var (',' var)*)? ')' (':' type)? '{' block '}'
     */
    private Function visitFunction () {
	auto ident = visitIdentifiant ();
	Array!Var exps;
	auto word = _lex.next ();
	if (word != Tokens.LPAR) throw new SyntaxError (word, [Tokens.LPAR.descr]);
	_lex.next (word);
	if (word != Tokens.RPAR) {
	    _lex.rewind ();
	    while (1) {
		exps.insertBack (visitVarDeclaration ());
		_lex.next (word);
		if (word == Tokens.RPAR) break;
		else if (word != Tokens.COMA)
		    throw new SyntaxError (word, [Tokens.RPAR.descr, Tokens.COMA.descr]);
	    }
	}

	_lex.next (word);
	if (word == Tokens.COLON) {
	    auto type = visitType ();
	    return new Function (ident, type, exps, visitBlock ());
	} else _lex.rewind ();	
	return new Function (ident, exps, visitBlock ());
    }

    /**
     var := type; 
     */
    private Var visitVar () {
	return visitType ();
    }

    /**
     vardecl := var (':' type)?
     */
    private Var visitVarDeclaration () {
	auto ident = visitIdentifiant ();
	Word next = _lex.next ();
	if (next == Tokens.COLON) {
	    auto type = visitType ();
	    return new TypedVar (ident, type);
	} else _lex.rewind ();
	return new Var (ident);
    }
    
    /**
     type := Identifiant ('!' (('(' expression (',' expression)* ')') | expression ) 
     */
    private Var visitType () {
	auto ident = visitIdentifiant ();
	auto next = _lex.next ();
	if (next == Tokens.NOT) {
	    Array!Expression params;
	    next = _lex.next ();
	    if (next == Tokens.LPAR) {
		while (1) {
		    params.insertBack (visitExpression ());
		    next = _lex.next ();
		    if (next == Tokens.RPAR) break;
		    else if (next != Tokens.COMA)
			throw new SyntaxError (next, [Tokens.RPAR.descr, Tokens.COMA.descr]);
		}
	    } else {
		_lex.rewind ();
		params.insertBack (visitExpression ());
	    }
	    return new Var (ident, params);
	} else _lex.rewind ();
	return new Var (ident);
    }
    
    /**
     Identifiant := ('_')* ([a-z]|[A-Z]) ([a-z]|[A-Z]|'_')|[0-9])*
     */
    private Word visitIdentifiant () {
	auto ident = _lex.next ();	
	if (ident.isToken ())
	    throw new SyntaxError (ident, ["'Identifiant'"]);
	
	if (find !"b == a" (this._forbiddenIds, ident) != [])
	    throw new SyntaxError (ident, ["'Identifiant'"]);
	
	if (ident.str.length == 0) throw new SyntaxError (ident, ["'Identifiant'"]);
	auto i = 0;
	foreach (it ; ident.str) {
	    if ((it >= 'a' && it <= 'z') || (it >= 'A' && it <= 'Z')) break;
	    else if (it != '_') throw new SyntaxError (ident, ["'identifiant'"]);
	    i++;
	}
	i++;
	if (ident.str.length < i)
	    throw new SyntaxError (ident, ["'Identifiant'"]);
	
	foreach (it ; ident.str [i .. $]) {
	    if ((it < 'a' || it > 'z')
		&& (it < 'A' || it > 'Z')
		&& (it != '_')
		&& (it < '0' || it > '9'))
		throw new SyntaxError (ident, ["'Identifiant'"]);
	}
	
	return ident;
    }

    /**
     block := '{' instruction* '}'
             | instruction
     */
    private Block visitBlock () {
	auto begin = _lex.next ();
	if (begin == Tokens.LACC) {
	    Array!Declaration decls;
	    Array!Instruction insts;
	    while (1) {
		auto next = _lex.next ();
		if (next == Keys.DEF) decls.insertBack (visitFunction ());
		else if (next == Keys.IMPORT) decls.insertBack (visitImport ());
		else if (next == Tokens.LACC) insts.insertBack (visitBlock ());
		else if (next == Tokens.SEMI_COLON) {}
		else if (next == Tokens.RACC) break;
		else {
		    _lex.rewind ();
		    insts.insertBack (visitInstruction ());
		}
	    }
	    return new Block (begin, decls, insts);
	} else _lex.rewind ();
	return new Block (begin,
			  make!(Array!Declaration),
			  make!(Array!Instruction) (visitInstruction ()));
    }

    /**
     instruction := if 
                  | return
		  | for
		  | while
		  | break
		  | delete
		  | let
		  | ';'
		  | expression

     */
    private Instruction visitInstruction () {
	auto tok = _lex.next ();
	if (tok == Keys.IF) return visitIf ();
	else if (tok == Keys.RETURN) return visitReturn ();
	else if (tok == Keys.WHILE) return visitWhile ();
	else if (tok == Keys.LET) return visitLet ();
	else if (tok == Tokens.SEMI_COLON) {
	    Warning.instance.warning_at (tok.locus,
				"Utilisez {} pour une instruction vide pas %s",
				tok.str);
	    return new Instruction (tok);
	} else {
	    _lex.rewind ();
	    auto retour = cast(Instruction)visitExpressionUlt ();
	    auto next = _lex.next ();
	    if (next != Tokens.SEMI_COLON) 
		throw new SyntaxError (next, [Tokens.SEMI_COLON.descr]);	    
	    return retour;
	}	
    }

    /**
     let := 'let' (var ('=' right)? ',')* (var ('=' right)? ';')
     */
    private Instruction visitLet () {
	_lex.rewind ();
	auto tok = _lex.next ();
	Word token;
	Array!Var decls;
	Array!Expression insts;
	while (1) {
	    auto var = visitVar ();
	    decls.insertBack (var);
	    _lex.next (token).rewind ();
	    if (token == Tokens.EQUAL) {
		auto next = visitExpressionUlt (var);
		
		if (next !is var) {
		    insts.insertBack (next);
		}
	    }
	    token = _lex.next ();
	    if (token == Tokens.SEMI_COLON) break;
	    else if (token != Tokens.COMA)
		throw new SyntaxError (token, [Tokens.SEMI_COLON.descr, Tokens.COMA.descr]);
	    
	}
	return new VarDecl (tok, decls, insts);
    }

    /**
     expressionult := expression (_ultimeop expression)*
     */
    private Expression visitExpressionUlt () {
	auto left = visitExpression ();
	auto tok = _lex.next ();
	if (find!"b == a"(_ultimeOp, tok) != []) {
	    auto right = visitExpression ();
	    return visitExpressionUlt (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }    

    private Expression visitExpressionUlt (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_ultimeOp, tok) != []) {
	    auto right = visitExpression ();
	    return visitExpressionUlt (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }

    private Expression visitExpression () {
	auto left = visitUlow ();
	auto tok = _lex.next ();
	if (find!"b == a" (_expOp, tok) != []) {
	    auto right = visitUlow ();
	    return visitExpression (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }

    private Expression visitExpression (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_expOp, tok) != []) {
	    auto right = visitUlow ();
	    return visitExpression (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }
    
    private Expression visitUlow () {
	auto left = visitLow ();
	auto tok = _lex.next ();
	if (find!"b == a" (_ulowOp, tok) != []) {
	    auto right = visitLow ();
	    return visitUlow (new Binary (tok, left, right));
	} else {
	    if (tok == Tokens.NOT) {
		auto suite = _lex.next ();
		if (suite == Keys.IS) {
		    suite.str = Tokens.NOT.descr ~ Keys.IS.descr;
		    auto right = visitLow ();
		    return visitUlow (new Binary (suite, left, right));
		} else _lex.rewind ();
	    }
	    _lex.rewind ();
	}
	return left;
    }

    private Expression visitUlow (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_ulowOp, tok) != []) {
	    auto right = visitLow ();
	    return visitUlow (new Binary (tok, left, right));
	} else {
	    if (tok == Tokens.NOT) {
		auto suite = _lex.next ();
		if (suite == Keys.IS) {
		    suite.str = Tokens.NOT.descr ~ Keys.IS.descr;
		    auto right = visitLow ();
		    return visitUlow (new Binary (suite, left, right));
		} else _lex.rewind ();
	    }
	    _lex.rewind ();
	}
	return left;
    }

    private Expression visitLow () {
	auto left = visitHigh ();
	auto tok = _lex.next ();
	if (find!"b == a" (_lowOp, tok) != []) {
	    auto right = visitHigh ();
	    return visitLow (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }

    private Expression visitLow (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_lowOp, tok) != []) {
	    auto right = visitHigh ();
	    return visitLow (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }

    private Expression visitHigh () {
    	auto left = visitPth ();
    	auto tok = _lex.next ();
    	if (find!"b == a" (_highOp, tok) != []) {
    	    auto right = visitPth ();
    	    return visitHigh (new Binary (tok, left, right));
    	} else _lex.rewind ();
    	return left;
    }

    private Expression visitHigh (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_highOp, tok) != []) {
	    auto right = visitPth ();
	    return visitHigh (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }
    
    private Expression visitPth () {
	auto tok = _lex.next ();
	if (find!"b == a" (_befUnary, tok) != []) {
	    return visitBeforePth (tok);
	} else {
	    if (tok == Tokens.LPAR)
		return visitPthPar ();
	    else return visitPthWPar (tok);
	}
    }

    private Expression visitPthPar () {
	auto exp = visitExpressionUlt ();
	auto tok = _lex.next ();
	if (tok != Tokens.RPAR)
	    throw new SyntaxError (tok, [Tokens.RPAR.descr]);
	tok = _lex.next ();
	if (find !"b == a" (_suiteElem, tok) != []) {
	    return visitSuite (tok, exp);
	} else if (find!"b == a" (_afUnary, tok) != []) {
	    return visitAfter (tok, exp);
	} else _lex.rewind ();
	return exp;
    }

    private Expression visitConstante () {
	auto tok = _lex.next ();
	if (tok.isEof ()) throw new SyntaxError (tok);
	if (tok.str [0] >= '0'&& tok.str [0] <= '9')
	    return visitNumeric (tok);
	else if (tok == Tokens.DOT)
	    return visitFloat (tok);
	else if (tok == Tokens.APOS || tok == Tokens.GUILL)
	    return visitString (tok);
	else if (tok == Keys.TRUE || tok == Keys.FALSE)
	    return new Bool (tok);
	else if (tok == Keys.NULL)
	    return new Null (tok);
	else _lex.rewind ();
	return null;
    }

    private Expression visitNumeric (Word begin) {
	foreach (it ; begin.str) {
	    if (it < '0' || it > '9')
		throw new SyntaxError (begin);	    
	}
	auto next = _lex.next ();
	if (next == Tokens.DOT) {
	    next = _lex.next ();
	    auto suite = next.str;
	    foreach (it ; next.str) {
		if (it < '0' || it > '9') {
		    suite = "0";
		    _lex.rewind ();
		    break;
		}		    
	    }
	    return new Float (begin, suite);
	} else _lex.rewind ();
	return new Int (begin);
    }    

    private Expression visitFloat (Word begin) {
	auto next = _lex.next ();
	foreach (it ; next.str) {
	    if (it < '0' || it > '9')
		throw new SyntaxError (next);	    
	}
	return new Float (next);
    }
    
    private short isChar (string value) {
	auto escape = ["\\a": '\a', "\\b" : '\b', "\\f" : '\f',
		       "\\n" : '\n', "\\r" : '\r', "\\t" : '\t',
		       "\\v" : '\v', "\\" : '\\',  "\'" : '\'',
		       "\"" : '\"', "\?": '\?'];

	if (value.length == 1) return cast(short) (value[0]);
	auto val = (value in escape);
	if (val !is null) return cast(short) *val;
	if (value[0] == Keys.ANTI.descr [0] && value.length == 4) {
	    if (value[1] == Keys.LX.descr [0]) {
		foreach (it ; value [1 .. $]) 
		    if ((it < 'a' || it > 'f') && (it < '0' || it > '9'))
			return -1;
		
	    } else if (value[0] == Keys.ANTI.descr [0] && value.length > 1 && value.length < 5) {
		foreach (it ; value [1 .. $]) 
		    if (it < '0' || it > '7') return -1;
		return -1;
	    }
	}
	return -1;
    }

    private Expression visitString (Word word) {
	_lex.skipEnable (Tokens.SPACE, false);
	_lex.commentEnable (false);
	Word next, beg;
	string val = "";
	while (1) {
	    next = _lex.next ();
	    if (next.isEof ()) throw new SyntaxError (next);
	    else if (next == word) break;
	    else val ~= next.str;
	}
	_lex.skipEnable (Tokens.SPACE);
	_lex.commentEnable ();
	if (word == Tokens.APOS) {
	    auto c = isChar (val);
	    if (c >= 0) return new Char (word, c);
	}
	return new String (word, val);
    }


    private Expression visitPthWPar (Word tok) {
	_lex.rewind ();
	auto constante = visitConstante ();
	if (constante !is null) return constante;
	auto left = visitLeftOp ();
	tok = _lex.next ();
	if (find ! "b == a" (_afUnary, tok) != []) {
	    return visitAfter (tok, left);
	} else _lex.rewind ();
	return left;
    }

    private Expression visitLeftOp () {
	auto var = visitVar ();
	auto next = _lex.next ();
	if (find!"b == a" (_suiteElem, next) != []) 
	    return visitSuite (next, var);
	else _lex.rewind ();
	return var;
    }

    private Expression visitSuite (Word token, Expression left) {
	if (token == Tokens.LPAR) return visitPar (left);
	else if (token == Tokens.LCRO) return visitAccess (left);
	else if (token == Tokens.DOT) return visitDot (left);
	else
	    throw new SyntaxError (token);
    }

    private Expression visitPar (Expression left) {
	_lex.rewind ();
	auto beg = _lex.next (), next = _lex.next ();
	auto suite = next;
	Array!Expression params;
	if (next != Tokens.RPAR) {
	    _lex.rewind ();
	    while (1) {
		params.insertBack (visitExpression ());
		next = _lex.next ();
		if (next == Tokens.RPAR) break;
		else if (next != Tokens.COMA)
		    throw new SyntaxError (next, [Tokens.RPAR.descr, Tokens.COMA.descr]);
	    }
	}
	auto retour = new Par (beg, left, new ParamList (suite, params));
	next = _lex.next ();
	if (find !"b == a" (_suiteElem, next) != [])
	    return visitSuite (next, retour);
	else if (find!"b == a" (_afUnary, next) != [])
	    return visitAfter (next, retour);
	_lex.rewind ();
	return retour;
    }

    private Expression visitAccess (Expression left) {
	_lex.rewind ();
	auto beg = _lex.next (), next = _lex.next ();
	auto suite = next;
	Array!Expression params;
	if (next != Tokens.RCRO) {
	    _lex.rewind ();
	    while (1) {
		params.insertBack (visitExpression ());
		next = _lex.next ();
		if (next == Tokens.RCRO) break;
		else if (next != Tokens.COMA)
		    throw new SyntaxError (next, [Tokens.RCRO.descr, Tokens.COMA.descr]);
	    }
	}
	auto retour = new Par (beg, left, new ParamList (suite, params));
	next = _lex.next ();
	if (find !"b == a" (_suiteElem, next) != [])
	    return visitSuite (next, retour);
	else if (find!"b == a" (_afUnary, next) != [])
	    return visitAfter (next, retour);
	_lex.rewind ();
	return retour;
    }

    private Expression visitDot (Expression left) {
	_lex.rewind ();
	auto begin = _lex.next ();
	auto right = visitVar ();
	auto retour = new Binary (begin, left, right);
	auto next = _lex.next ();
	if (find !"b == a" (_suiteElem, next) != [])
	    return visitSuite (next, retour);
	else if (find!"b == a" (_afUnary, next) != [])
	    return visitAfter (next, retour);
	_lex.rewind ();
	return retour;
    }

    private Expression visitAfter (Word word, Expression left) {
	return new AfUnary (word, left);
    }
    
    private Expression visitBeforePth (Word word) {
	auto elem = visitPth ();
	return new BefUnary (word, elem);
    }
    
    private Instruction visitIf () {
	_lex.rewind ();
	auto begin = _lex.next ();
	auto test = visitExpression ();
	auto block = visitBlock ();
	auto next = _lex.next ();
	if (next == Keys.ELSE) {
	    return new If (begin, test, block, visitElse ()); 
	} else _lex.rewind ();
	return new If (begin, test, block);
    }

    private Else visitElse () {
	_lex.rewind ();
	auto begin = _lex.next (), next = _lex.next ();
	if (next == Keys.IF) {
	    auto test = visitExpression ();
	    auto block = visitBlock ();
	    next = _lex.next ();
	    if (next == Keys.ELSE) {
		return new ElseIf (begin, test, block, visitElse ());
	    } else _lex.rewind ();
	    return new ElseIf (begin, test, block);
	} else _lex.rewind ();
	return new Else (begin, visitBlock ());
    }

    private Instruction visitReturn () {
	_lex.rewind ();
	auto begin = _lex.next (), next = _lex.next ();
	if (next == Tokens.SEMI_COLON) 
	    return new Return (begin);
	else _lex.rewind ();
	auto exp = visitExpression ();
	next = _lex.next ();
	if (next != Tokens.SEMI_COLON) 
	    throw new SyntaxError (next, [Tokens.SEMI_COLON.descr]);
	return new Return (begin, exp);	
    }
    
    
    private Instruction visitWhile () {
	_lex.rewind ();
	auto begin = _lex.next ();
	auto test = visitExpression ();
	return new While (begin, test, visitBlock ());
    }
    
    
}
