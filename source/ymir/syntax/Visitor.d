module ymir.syntax.Visitor;
import ymir.syntax._;
import ymir.ast._;
import ymir.utils._;

import std.stdio, std.outbuffer, std.container;
import std.algorithm, std.conv;
import std.math;

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
    private Token[] _decoKeys;
    private bool _lambdaPossible;
    
    this (string file) {
	this ();
	this._lex = new Lexer (file,
			       [Tokens.SPACE, Tokens.RETOUR, Tokens.RRETOUR, Tokens.TAB],
			       [[Tokens.LCOMM1, Tokens.RCOMM1],
				[Tokens.LCOMM2, Tokens.RETOUR],
			        [Tokens.LCOMM3, Tokens.RCOMM3]]);
    }
    
    this () {	
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

	this._highOp = [Tokens.DIV, Tokens.AND, Tokens.STAR, Tokens.PERCENT,
			Tokens.DXOR];
	
	this._suiteElem = [Tokens.LPAR, Tokens.LCRO, Tokens.DOT, Tokens.DCOLON];
	this._afUnary = [Tokens.DPLUS, Tokens.DMINUS];	
	this._befUnary = [Tokens.MINUS, Tokens.AND, Tokens.STAR, Tokens.NOT];
	this._forbiddenIds = [Keys.IMPORT, Keys.STRUCT,
			      Keys.DEF, Keys.IF, Keys.RETURN,
			      Keys.FOR,  Keys.WHILE, Keys.BREAK,
			      Keys.MATCH, Keys.IN, Keys.ELSE,
			      Keys.TRUE, Keys.FALSE, Keys.NULL, Keys.CAST,
			      Keys.FUNCTION, Keys.LET, Keys.IS, Keys.EXTERN,
			      Keys.PUBLIC, Keys.PRIVATE, Keys.TYPEOF, Keys.IMMUTABLE,
			      Keys.CONST, Keys.REF, Keys.TRAIT
	];

	this._decoKeys = [Keys.IMMUTABLE, Keys.CONST, Keys.STATIC];
	this._lambdaPossible = true;
    }

    ref Lexer lexer () {
	return this._lex;
    }
    
    /**
     program := function | import | struct | class;
     */
    Program visit () {
	auto begin = this._lex.next ();
	Word word = begin;
	Array!Declaration decls;
	while (!word.isEof ()) {
	    if (word == Keys.DEF) decls.insertBack (this.visitFunction ());
	    else if (word == Keys.IMPORT) decls.insertBack (this.visitImport ());
	    else if (word == Keys.EXTERN) decls.insertBack (this.visitExtern ());
	    else if (word == Keys.STRUCT) decls.insertBack (this.visitStruct ());
	    else if (word == Keys.ENUM) decls.insertBack (this.visitEnum ());
	    else if (word == Keys.STATIC) decls.insertBack (this.visitGlobal ());
	    else if (word == Keys.SELF) decls.insertBack (this.visitSelf ());
	    else if (word == Keys.TRAIT) decls.insertBack (this.visitTrait ());
	    else if (word == Keys.IMPL) decls.insertBack (this.visitImpl ());
	    else if (word == Keys.PUBLIC) {
		auto pub_decls = visitPublicBlock ();
		foreach (it ; pub_decls) decls.insertBack (it);
	    } else if (word == Keys.PRIVATE) {
		auto prv_decls = visitPrivateBlock ();
		foreach (it ; prv_decls) decls.insertBack (it);
	    }
	    else throw new SyntaxError (word);
	    _lex.next (word);
	}
	return new Program (begin, decls);
    }

    Array!Declaration visitPublicBlock () {
	auto next = this._lex.next ();
	Array!Declaration decls;
	if (next == Tokens.LACC) {
	    while (true) {
		auto word = this._lex.next ();
		if (word == Keys.DEF) decls.insertBack (this.visitFunction ());
		else if (word == Keys.EXTERN) decls.insertBack (this.visitExtern ());
		else if (word == Keys.STRUCT) decls.insertBack (this.visitStruct ());
		else if (word == Keys.IMPORT) decls.insertBack (this.visitImport ());
		else if (word == Keys.ENUM) decls.insertBack (this.visitEnum ());
		else if (word == Keys.TRAIT) decls.insertBack (this.visitTrait ());
		else if (word == Keys.IMPL) decls.insertBack (this.visitImpl ());
		else if (word == Tokens.RACC) break;
		else throw new SyntaxError (word);
		decls.back ().isPublic = true;
	    }
	} else {
	    if (next == Keys.DEF) decls.insertBack (this.visitFunction ());
	    else if (next == Keys.EXTERN) decls.insertBack (this.visitExtern ());
	    else if (next == Keys.STRUCT) decls.insertBack (this.visitStruct ());
	    else if (next == Keys.IMPORT) decls.insertBack (this.visitImport ());
	    else if (next == Keys.TRAIT) decls.insertBack (this.visitTrait ());
	    else if (next == Keys.IMPL) decls.insertBack (this.visitImpl ());
	    else if (next == Keys.ENUM) decls.insertBack (this.visitEnum ());
	    else throw new SyntaxError (next);
	    decls.back ().isPublic = true;
	}
	return decls;
    }

    Array!Declaration visitPrivateBlock () {
	auto next = this._lex.next ();
	Array!Declaration decls;
	if (next == Tokens.LACC) {
	    while (true) {
		auto word = this._lex.next ();
		if (word == Keys.DEF) decls.insertBack (this.visitFunction ());
		else if (word == Keys.EXTERN) decls.insertBack (this.visitExtern ());
		else if (word == Keys.STRUCT) decls.insertBack (this.visitStruct ());
		else if (word == Keys.IMPORT) decls.insertBack (this.visitImport ());
		else if (word == Keys.TRAIT) decls.insertBack (this.visitTrait ());
		else if (word == Keys.IMPL) decls.insertBack (this.visitImpl ());
		else if (word == Keys.ENUM) decls.insertBack (this.visitEnum ());
		else if (word == Tokens.RACC) break;
		else throw new SyntaxError (word);
		decls.back ().isPublic = false;
	    }
	} else {	    
	    if (next == Keys.DEF) decls.insertBack (this.visitFunction ());
	    else if (next == Keys.EXTERN) decls.insertBack (this.visitExtern ());
	    else if (next == Keys.STRUCT) decls.insertBack (this.visitStruct ());
	    else if (next == Keys.IMPORT) decls.insertBack (this.visitImport ());
	    else if (next == Keys.TRAIT) decls.insertBack (this.visitTrait ());
	    else if (next == Keys.IMPL) decls.insertBack (this.visitImpl ());
	    else if (next == Keys.ENUM) decls.insertBack (this.visitEnum ());
	    else throw new SyntaxError (next);
	    decls.back ().isPublic = false;
	}
	return decls;
    }	


    private Impl visitImpl () {
	auto ident = visitIdentifiant ();
	Word what = Word.eof;
	auto next = this._lex.next (Keys.FROM, Tokens.LACC);
	
	if (next == Keys.FROM) {
	    what = visitIdentifiant ();	
	    this._lex.next (Tokens.LACC);
	}
	
	next = this._lex.next (Tokens.RACC, Keys.DEF, Keys.OVER);
	Array!Function methods; Array!bool herit;
	Array!Constructor csts;
	bool isOver = (next == Keys.OVER);
	if (isOver && what.isEof) throw new SyntaxError (next, [Tokens.RACC.descr, Keys.DEF.descr]);
	if (next != Tokens.RACC) {
	    while (true) {
		auto meth = visitFunctionImpl ();
		if (auto fn = cast (Function) meth) {
		    methods.insertBack (fn);
		    herit.insertBack (isOver);
		} else csts.insertBack (cast (Constructor) meth);
		next = this._lex.next (Tokens.RACC, Keys.DEF, Keys.OVER);
		if (next == Tokens.RACC) break;
		else if (next == Keys.OVER) {
		    if (what.isEof) throw new SyntaxError (next, [Tokens.RACC.descr, Keys.DEF.descr]);
		    isOver = true;
		} else isOver = false;
	    }
	}
	if (what.isEof) 
	    return new Impl (ident, methods, csts);
	else
	    return new Impl (what, ident, methods, herit, csts);
    }

    private Constructor visitConstructor () {
	auto begin = this._lex.next (Keys.SELF);
	Array!Var params;
	while (true) {
	    auto next = this._lex.next (Tokens.COMA, Tokens.RPAR);
	    if (next == Tokens.RPAR) break;
	    else {
		params.insertBack (visitVarDeclaration ());
	    }
	}
	return new Constructor (begin, params, visitBlock ());
    }
    
    private Declaration visitFunctionImpl () {
	auto begin = this._lex.rewind ().next ();       
	auto next = this._lex.next ();
	if (next == Tokens.LPAR && begin == Keys.DEF) return visitConstructor ();
	else this._lex.rewind ();
	auto ident = visitIdentifiant ();
	Array!Var params;
	this._lex.next (Tokens.LPAR);
	next = this._lex.next ();	
	if (next != Tokens.RPAR) {
	    this._lex.rewind ();
	    while (true) {
		if (params.length == 0) {
		    next = this._lex.next ();
		    if (next == Keys.SELF)
			params.insertBack (new Var (next));		    
		    else {
			this._lex.rewind ();
			params.insertBack (visitVarDeclaration ());
		    }
		} else
		    params.insertBack (visitVarDeclaration ());
		next = this._lex.next (Tokens.RPAR, Tokens.COMA);
		if (next == Tokens.RPAR) break;
	    }
	}

	Var type;
	next = this._lex.next ();
	if (next == Tokens.COLON) {
	    auto deco = this._lex.next ();
	    if (deco != Keys.REF) {
		deco = Word.eof;
		this._lex.rewind ();
	    }	    
	    type = visitType ();
	    type.deco = deco;
	} else this._lex.rewind ();
	
	return new Function (ident, params, make!(Array!Expression), null, visitBlock);
    }


    
    /++
     traitProto := 'def' Identifiant '(' (var (',' var)*)? ')' ':' type ';'
     +/
    private TraitProto visitTraitProto () {
	auto ident = visitIdentifiant ();
	Array!Var params;
	this._lex.next (Tokens.LPAR);
	auto next = this._lex.next ();
	if (next != Tokens.RPAR) {
	    this._lex.rewind ();	
	    while (true) {
		params.insertBack (visitVarDeclaration ());
		next = this._lex.next (Tokens.RPAR, Tokens.COMA);
		if (next == Tokens.RPAR) break;
	    }
	}

	Var type;
	next = this._lex.next (Tokens.COLON, Tokens.SEMI_COLON);
	if (next == Tokens.COLON) {
	    auto deco = this._lex.next ();
	    if (deco != Keys.REF) {
		deco = Word.eof;
		this._lex.rewind ();
	    }
	    type = visitType ();
	    type.deco = deco;
	    this._lex.next (Tokens.SEMI_COLON);
	}
	return new TraitProto (ident, params, type);
    }
    
    /++
     trait := 'trait' Identifiant '{' traitProto* '}'
     +/
    private Trait visitTrait () {
	Array!TraitProto meth;
	auto ident = visitIdentifiant ();
	this._lex.next (Tokens.LACC);

	while (true) {
	    auto next = this._lex.next (Tokens.RACC, Keys.DEF);
	    if (next == Keys.DEF) {
		meth.insertBack (visitTraitProto ());
	    } else break;
	}
	return new Trait (ident, meth);
    }
    
    /++
     self := 'self' '(' ')' block
     +/
    private Self visitSelf () {
	Array!Instruction insts;
	this._lex.rewind ();
	auto begin = this._lex.next ();
	this._lex.next (Tokens.LPAR);
	this._lex.next (Tokens.RPAR);
	return new Self (begin, visitBlock ());	
    }    
    
    /++
     global = 'static' (Identifiant '=' expression) ';'
     +/
    private Global visitGlobal () {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto ident = visitIdentifiant ();	
	auto next = this._lex.next (Tokens.EQUAL, Tokens.COLON);
	if (next == Tokens.EQUAL) {
	    auto expr = visitExpression ();
	    this._lex.next (Tokens.SEMI_COLON);
	    return new Global (ident, expr);
	} else {
	    Expression type;
	    next = this._lex.next ();
	    if (next == Keys.FUNCTION) type = visitFuncPtrSimple ();
	    else {
		this._lex.rewind ();
		type = visitType ();
	    }
	    this._lex.next (Tokens.SEMI_COLON);
	    return new Global (ident, null, type);
	}
    }

    private string visitSpace () {
	auto buf = new OutBuffer ();
	while (true) {	    
	    auto next = visitIdentifiant ();
	    buf.writef ("%s", next.str);
	    auto nt = this._lex.next ();
	    if (nt == Tokens.DOT) buf.write (".");
	    else break;
	}
	this._lex.rewind ();
	return buf.toString ();
    }    
    
    /**
     import := 'import' (Identifiant ('.' Identifiant)*) (',' Identifiant ('.' Identifiant))* ';'
     */
    private Import visitImport () {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	Array!(Word) idents;
	bool end = true;
	while (true) {
	    auto name = this._lex.next ();
	    if (!end && name == Keys.UNDER) {		
		idents.back.str = idents.back.str ~ name.str;
		auto word = this._lex.next ();
		if (word == Tokens.COMA) end = true;
		else if (word != Tokens.SEMI_COLON) throw new SyntaxError (word, [Tokens.COMA.descr, Tokens.SEMI_COLON.descr]);
		else break;
	    } else {
		this._lex.rewind ();
		auto ident = visitIdentifiant ();
		if (end) {
		    end = false;
		    idents.insertBack (ident);	    
		} else idents.back.str = idents.back.str ~ ident.str;
		auto word = this._lex.next ();
		if (word == Tokens.DOT) idents.back.str = idents.back.str ~ '/';
		else if (word == Tokens.COMA) {
		    end = true;
		} else if (word != Tokens.SEMI_COLON) throw new SyntaxError (word, [Tokens.DOT.descr, Tokens.COMA.descr, Tokens.SEMI_COLON.descr]);
		else break;
	    }
	}
	return new Import (begin, idents);
    }

    Array!Expression visitTemplateStruct () {
	Array!Expression expr;
	auto next = this._lex.next ();
	if (next != Tokens.RPAR) {
	    this._lex.rewind ();
	    while (next != Tokens.RPAR) {	    
		expr.insertBack (visitOf ());
		next = this._lex.next (Tokens.RPAR, Tokens.COMA);
	    }
	}
	return expr;
    }
    
    /**
     struct := 'struct' '(' (var (',' var)*)? ')' Identifiant ';'
     */
    private Struct visitStruct () {
	Word word = this._lex.next (), ident;
	Array!Var exps;
	Array!Expression temps;
	if (word == Tokens.LPAR) {
	    temps = visitTemplateStruct ();
	    word = this._lex.next (Tokens.PIPE);
	}
	
	if (word == Tokens.PIPE) {
		while (true) {
		exps.insertBack (visitStructVarDeclaration ());
		this._lex.next (word);
		if (word == Tokens.ARROW) break;
		else if (word != Tokens.PIPE)
		    throw new SyntaxError (word, [Tokens.PIPE.descr, Tokens.COMA.descr]);
	    }
	    ident = visitIdentifiant ();
	    word = this._lex.next ();
	    if (word != Tokens.SEMI_COLON) throw new SyntaxError (word, [Tokens.SEMI_COLON.descr]);	    
	} else if (word != Tokens.ARROW) {
	    this._lex.rewind ();
	    ident = visitIdentifiant ();
	    auto next = this._lex.next (Tokens.LPAR, Tokens.LACC);
	    if (next == Tokens.LPAR) {
		temps = visitTemplateStruct ();
		this._lex.next (Tokens.LACC); 
	    }
	    next = this._lex.next ();
	    if (next != Tokens.RACC) {
		this._lex.rewind ();
		while (true) {
		    exps.insertBack (visitStructVarDeclaration ());
		    word = this._lex.next (Tokens.COMA, Tokens.RACC);
		    if (word == Tokens.RACC) break;
		}
	    } 
	} else {
	    ident = visitIdentifiant ();
	    this._lex.next (Tokens.COMA);
	}	
	return new Struct (ident, temps, exps);	
    }    

    /**
     enum := 'enum' (Identifiant ':' type ('|' Identifiant ':' expression) * '->' Identifiant ';')
     | (Identifiant  '=' expression ';') 
    */
    private Enum visitEnum () {
	Array!Word names;
	Array!Expression values;
	auto word = this._lex.next ();
	Word ident;
	Var type;
	if (word == Tokens.COLON) type = visitType ();
	else this._lex.rewind ();
	word = this._lex.next ();
	if (word != Tokens.PIPE)  {
	    this._lex.rewind ();
	    ident = visitIdentifiant ();
	    auto next = this._lex.next (Tokens.COLON, Tokens.LACC);
	    if (next == Tokens.COLON) type = visitType ();
	    while (true) {
		names.insertBack (visitIdentifiant);
		next = this._lex.next (Tokens.COLON);
		values.insertBack (visitPth ());
		next = this._lex.next (Tokens.RACC, Tokens.COMA);
		if (next == Tokens.RACC) break;
	    }
	} else {
	    while (true) {
		names.insertBack (visitIdentifiant ());
		auto next = this._lex.next (Tokens.COLON);
		values.insertBack (visitPth ());
		next = this._lex.next (Tokens.ARROW, Tokens.PIPE);
		if (next == Tokens.ARROW) break;
	    }
	
	    ident = visitIdentifiant ();       	    
	    word = this._lex.next (Tokens.SEMI_COLON);
	}
	return new Enum (ident, type, names, values);
    }


    private Expression visitIfFunction () {
	auto next = this._lex.next ();
	bool lpar = false;
	if (next == Tokens.LPAR) lpar = true;
	else this._lex.rewind ();
	auto expr = visitExpression ();
	if (lpar) {
	    next = this._lex.next( );
	    if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	}
	return expr;
    }
    
    /**
     function := 'def' Identifiant ('(' var (',') var)* ')' )? '(' (var (',' var)*)? ')' (':' type)? '{' block '}'
     */
    private Function visitFunction () {
	auto ident = visitIdentifiant ();
	bool templates = false;
	Array!Var exps; Array!Expression temps;
	auto word = _lex.next (), _ifToken = word;
	Expression test = null;
	if (word == Keys.IF) { test = visitIfFunction (); word = this._lex.next (); }
	if (word != Tokens.LPAR) throw new SyntaxError (word, [Tokens.LPAR.descr]);
	_lex.next (word);
	if (word != Tokens.RPAR) {
	    _lex.rewind ();
	    while (1) {
		auto constante = visitConstante ();
		if (constante is null) 
		    temps.insertBack (visitOf ());
		else {
		    templates = true;
		    temps.insertBack (constante);
		}
		_lex.next (word);
		if (word == Tokens.RPAR) break;
		else if (word != Tokens.COMA)
		    throw new SyntaxError (word, [Tokens.RPAR.descr, Tokens.COMA.descr]);
	    }
	}
	
	_lex.next (word);
	if (word == Tokens.LPAR) {
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
	} else if (!templates) {
	    if (test) throw new SyntaxError (_ifToken, [Tokens.LPAR.descr]);
	    foreach (it ; temps) exps.insertBack (cast (Var) it);
	    temps.clear ();
	} else throw new SyntaxError (word, [Tokens.LPAR.descr]);
	
	if (word == Tokens.COLON) {
	    auto deco = this._lex.next ();
	    if (deco != Keys.REF) {
		deco = Word.eof;
		this._lex.rewind ();
	    }
	    auto type = visitType ();
	    type.deco = deco;
	    return new Function (ident, type, exps, temps, test, visitBlock ());
	} else _lex.rewind ();	
	return new Function (ident, exps, temps, test, visitBlock ());
    }

    /**
     extern := 'extern' ('(' Identifiant ')')? Identifiant '(' (var (',' var)*)? ')' (':' type)? ';'
     */
    private Proto visitExtern () {
	auto word = _lex.next ();
	bool isVariadic = false;
	Word from = Word.eof;
	string space = "";
	if (word == Tokens.LPAR) {
	    from = visitIdentifiant ();
	    word = _lex.next (Tokens.COMA, Tokens.RPAR);
	    if (word == Tokens.COMA) {
		if (from.str != Keys.DLANG.descr) throw new SyntaxError (word, [Tokens.RPAR.descr]);
		space = visitSpace ();
		_lex.next (Tokens.RPAR);
	    }
	} else _lex.rewind ();
	auto ident = visitIdentifiant ();
	Array!Var exps;

	word = _lex.next ();
	if (word != Tokens.LPAR) throw new SyntaxError (word, [Tokens.LPAR.descr]);
	_lex.next (word);
	if (word != Tokens.RPAR) {
	    _lex.rewind ();
	    while (1) {
		word = this._lex.next ();
		if (word == Tokens.TDOT) {
		    isVariadic = true;
		    word = this._lex.next ();
		    if (word != Tokens.RPAR) throw new SyntaxError (word, [Tokens.RPAR.descr]);
		    break;
		} else this._lex.rewind ();
		exps.insertBack (visitVarDeclaration ());
		_lex.next (word);
		if (word == Tokens.RPAR) break;
		else if (word != Tokens.COMA)
		    throw new SyntaxError (word, [Tokens.RPAR.descr, Tokens.COMA.descr]);
	    }
	}
	_lex.next (word);
	Var type = null;
	if (word == Tokens.COLON) {
	    type = visitType ();
	    word = _lex.next ();
	}
	
	if (word != Tokens.SEMI_COLON) throw new SyntaxError (word, [Tokens.SEMI_COLON.descr]);	
	auto ret = new Proto (ident, type, exps, space, isVariadic);
	ret.from = from;
	return ret;
    }
    
    /**
     var := type; 
     */
    private Var visitVar () {
	return visitType ();
    }

    private Expression visitOf () {
	auto deco = this._lex.next ();
	if (deco != Keys.CONST && deco != Keys.REF) {
	    this._lex.rewind ();
	    deco = Word.eof;
	}
	
	auto ident = visitIdentifiant ();
	Word next = this._lex.next ();
	if (next == Tokens.COLON) {
	    next = this._lex.next ();
	    if (next == Keys.FUNCTION) {
		auto type = visitFuncPtrSimple ();
		return new TypedVar (ident, type, deco);
	    } else {
		this._lex.rewind ();
		auto type = visitType ();
		return new TypedVar (ident, type, deco);
	    }
	} else if (next == Keys.OF && deco.isEof) {
	    auto type = visitType ();
	    return new OfVar (ident, type);	    
	} else if (next == Tokens.TDOT) {
	    return new VariadicVar (ident);
	} else this._lex.rewind ();
	return new Var (ident, deco);
    }
    
    /**
     vardecl := var (':' type)?
     */
    private Var visitVarDeclaration () {
	auto deco = this._lex.next ();
	if (deco != Keys.CONST && deco != Keys.REF) {
	    this._lex.rewind ();
	    deco = Word.eof;
	}
	auto ident = visitIdentifiant ();
	Word next = _lex.next ();
	if (next == Tokens.COLON) {
	    next = _lex.next ();
	    if (next == Keys.FUNCTION) {
		auto type = visitFuncPtrSimple ();
		return new TypedVar (ident, type, deco);
	    } else {
		_lex.rewind ();
		auto type = visitType ();
		return new TypedVar (ident, type, deco);
	    }
	} else _lex.rewind ();
	return new Var (ident, deco);
    }

    private TypedVar visitStructVarDeclaration () {
	auto ident = visitIdentifiant ();
	Word next  = _lex.next (Tokens.COLON);
	next = _lex.next ();
	if (next == Keys.FUNCTION) {
	    auto type = visitFuncPtrSimple ();
	    return new TypedVar (ident, type, Word.eof);
	} else if (next == Tokens.LCRO) {
	    auto begin = next;
	    next = this._lex.next ();
	    Expression type;
	    if (next == Keys.FUNCTION) type = visitFuncPtrSimple ();
	    else {
		this._lex.rewind ();
		type = visitType ();
	    }
	    next = this._lex.next (Tokens.RCRO, Tokens.SEMI_COLON);
	    if (next == Tokens.SEMI_COLON) {
		auto len = visitNumeric (this._lex.next ());
		this._lex.next (Tokens.RCRO);
		return new TypedVar (ident, new ArrayAlloc (begin, type, len), Word.eof);
	    } else return new TypedVar (ident, new ArrayVar (begin, type), Word.eof);
	} else {
	    _lex.rewind ();
	    auto type = visitType ();
	    return new TypedVar (ident, type, Word.eof);
	}
    }    

    private TypedVar visitTypedVarDeclaration () {
	auto deco = this._lex.next ();
	if (deco != Keys.CONST && deco != Keys.REF) {
	    this._lex.rewind ();
	    deco = Word.eof;
	}
	auto ident = visitIdentifiant ();
	Word next = _lex.next ();
	if (next == Tokens.COLON) {
	    next = _lex.next ();
	    if (next == Keys.FUNCTION) {
		auto type = visitFuncPtrSimple ();
		return new TypedVar (ident, type, deco);
	    } else {
		_lex.rewind ();
		auto type = visitType ();
		return new TypedVar (ident, type, deco);
	    }
	} throw new SyntaxError (next, [Tokens.COLON.descr]);
    }
    

    /**
     vardecl := var (':' type)?
     */
    private bool canVisitVarDeclaration () {
	auto nb = this._lex.tell (), ret = false;
	auto deco = this._lex.next ();
	if (deco != Keys.CONST && deco != Keys.REF) {
	    this._lex.rewind ();
	    deco = Word.eof;
	}
	
	if (canVisitIdentifiant ()) {
	    auto ident = visitIdentifiant ();
	    Word next = _lex.next ();
	    if (next == Tokens.COLON) {
		ret = true;
	    }
	}
	this._lex.seek (nb);
	return ret;
    }

    
    
    /**
     type := Identifiant ('!' (('(' expression (',' expression)* ')') | expression ) 
     */
    private Var visitType () {
	auto begin = this._lex.next ();
	if (begin == Tokens.LCRO) {
	    auto next = this._lex.next ();
	    Expression type;
	    if (next == Keys.FUNCTION) 
		type = visitFuncPtrSimple ();
	    else { 
		this._lex.rewind ();
		type = visitType ();
	    }
	    
	    auto end = this._lex.next ();
	    if (end != Tokens.RCRO) throw new SyntaxError (end, [Tokens.RCRO.descr]);
	    return new ArrayVar (begin, type);
	} else this._lex.rewind ();
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
	    } else if (next != Keys.IS) {
		_lex.rewind ();
		auto constante = visitConstante ();
		if (constante !is null) 
		    params.insertBack (constante);
		else {
		    auto ident_ = visitIdentifiant ();
		    params.insertBack (new Var (ident_));
		}
	    } else _lex.rewind (2);
	    return new Var (ident, params);
	} else _lex.rewind ();
	return new Var (ident);
    }
    
    /**
     Identifiant := ('_')* ([a-z]|[A-Z]) ([a-z]|[A-Z]|'_')|[0-9])*
     */
    private Word visitIdentifiant () {
	auto ident = _lex.next ();
	if (ident.isEof () && this._lex.isMixinContext)
	    return Word.eof ();
	
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

    private bool canVisitIdentifiant () {	
	auto ident = _lex.next ();
	this._lex.rewind ();
	if (ident.isToken ())
	    return false;
	
	if (find !"b == a" (this._forbiddenIds, ident) != [])
	    return false;
	
	if (ident.str.length == 0) return false;
	auto i = 0;
	foreach (it ; ident.str) {
	    if ((it >= 'a' && it <= 'z') || (it >= 'A' && it <= 'Z')) break;
	    else if (it != '_') return false;
	    i++;
	}
	i++;
	if (ident.str.length < i)
	    return false;
	
	foreach (it ; ident.str [i .. $]) {
	    if ((it < 'a' || it > 'z')
		&& (it < 'A' || it > 'Z')
		&& (it != '_')
		&& (it < '0' || it > '9'))
		return false;
	}
	
	return true;
    }
    
    Block visitBlockOutSide () {
	return visitBlock ();
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
		else if (next == Keys.EXTERN) decls.insertBack (visitExtern ());
		else if (next == Keys.STRUCT) decls.insertBack (this.visitStruct ());
		else if (next == Tokens.LACC) {
		    this._lex.rewind ();
		    insts.insertBack (visitBlock ());		
		} else if (next == Tokens.SEMI_COLON) {}
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
		  | assert
		  | let
		  | static
		  | ';'
		  | expression		  

     */
    private Instruction visitInstruction () {
	auto tok = _lex.next ();
	if (tok == Keys.IF) return visitIf ();
	else if (tok == Keys.RETURN) return visitReturn ();
	else if (tok == Keys.FOR) return visitFor ();
	else if (tok == Keys.WHILE) return visitWhile ();
	else if (tok == Keys.LET) return visitLet ();
	else if (tok == Keys.BREAK) return visitBreak ();
	else if (tok == Keys.ASSERT) return visitAssert ();
	else if (tok == Keys.STATIC) {
	    tok = this._lex.next ();
	    Instruction inst;
	    if (tok == Keys.IF) inst = visitIf ();
	    else if (tok == Keys.ASSERT) inst = visitAssert ();
	    else throw new SyntaxError (tok, [Keys.IF.descr, Keys.ASSERT.descr]);
	    inst.isStatic = true;
	    return inst;
	}
	else if (tok == Tokens.SEMI_COLON) {
	    Warning.instance.warning_at (tok.locus,
				"Utilisez {} pour une instruction vide pas %s",
				tok.str);
	    return new None (tok);
	} else {
	    _lex.rewind ();
	    auto retour = cast(Instruction)visitExpressionUlt ();
	    if (!cast (Match) retour) {
		auto next = _lex.next ();	    
		if (next != Tokens.SEMI_COLON) 
		    throw new SyntaxError (next, [Tokens.SEMI_COLON.descr]);
	    }
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
	Array!Word decos;
	Array!Expression insts;
	auto nextW = this._lex.next ();
	if (nextW == Tokens.LPAR) return visitLetDestruct (tok);
	else this._lex.rewind;
	while (1) {
	    auto deco = this._lex.next ();
	    if (find (_decoKeys, deco) != [])
		decos.insertBack (deco);
	    else {
		decos.insertBack (Word.eof); this._lex.rewind ();
	    }

	    auto var = visitVar ();
	    decls.insertBack (var);
	    _lex.next (token).rewind ();
	    if (token == Tokens.EQUAL) {
		auto next = visitExpressionUlt (var);		
		if (next !is var) {
		    insts.insertBack (next);
		} else insts.insertBack (null);
	    } else {
		insts.insertBack (null);
	    }
	    token = _lex.next ();
	    if (token == Tokens.SEMI_COLON) break;
	    else if (token != Tokens.COMA)
		throw new SyntaxError (token, [Tokens.SEMI_COLON.descr, Tokens.COMA.descr]);
	    
	}
	return new VarDecl (tok, decos, decls, insts);
    }

    /++
     letDest := let '(' (var (',' var)*) ')' '=' right ';'
     +/
    private Instruction visitLetDestruct (Word begin) {
	bool isVariadic;
	Array!Var decls;
	while (true) {
	    decls.insertBack (visitVar ());
	    auto next = this._lex.next (Tokens.COMA, Tokens.RPAR, Tokens.TDOT);
	    if (next == Tokens.RPAR) break;
	    else if (next == Tokens.TDOT) {
		isVariadic = true;
		this._lex.next (Tokens.RPAR);
		break;
	    }
	}

	auto next = this._lex.next (Tokens.EQUAL);
	auto right = this.visitExpressionUlt ();
	this._lex.next (Tokens.SEMI_COLON);
	return new TupleDest (begin, isVariadic, decls, right);
    }    

    public Expression visitExpressionOutSide () {
	return this.visitExpressionUlt ();
    }
    
    /**
     expressionult := expression (_ultimeop expression)*
     */
    private Expression visitExpressionUlt () {
	auto left = visitExpression ();
	auto tok = _lex.next ();
	if (find!"b == a"(_ultimeOp, tok) != []) {
	    auto right = visitExpressionUlt ();
	    return visitExpressionUlt (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }    

    private Expression visitExpressionUlt (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_ultimeOp, tok) != []) {
	    auto right = visitExpressionUlt ();
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
	if (find!"b == a" (_ulowOp, tok) != [] || tok == Keys.IS) {
	    auto right = visitLow ();
	    return visitUlow (new Binary (tok, left, right));
	} else {
	    if (tok == Tokens.NOT) {
		auto suite = _lex.next ();
		if (suite == Keys.IS) {
		    auto right = visitLow ();
		    tok.str = Keys.NOT_IS.descr;
		    return visitUlow (new Binary (tok, left, right));
		} else _lex.rewind ();
	    } else if (tok == Tokens.DDOT) {
		auto right = visitLow ();
		return visitUlow (new ConstRange (tok, left, right));
	    } 
	    _lex.rewind ();
	}
	return left;
    }

    private Expression visitUlow (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_ulowOp, tok) != [] || tok == Keys.IS) {
	    auto right = visitLow ();
	    return visitUlow (new Binary (tok, left, right));
	} else {
	    if (tok == Tokens.NOT) {
		auto suite = _lex.next ();
		if (suite == Keys.IS) {
		    auto right = visitLow ();
		    tok.str = Keys.NOT_IS.descr;
		    return visitUlow (new Binary (tok, left, right));
		} else _lex.rewind ();
	    } else if (tok == Tokens.DDOT) {
		auto right = visitLow ();
		return visitHigh (new ConstRange (tok, left, right));
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
    	} else if (tok == Keys.IN) {
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
	} else if (tok == Keys.IN) {
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
		return visitPthPar (tok);
	    else return visitPthWPar (tok);
	}
    }

    private Expression visitPthPar (Word token) {
	Array!Expression params;
	Expression exp;
	Word tok, next;
	bool isTuple = false;
	if (this._lambdaPossible && canVisitVarDeclaration ()) return visitLambda ();
	tok = this._lex.next ();	
	if (tok == Tokens.RPAR) {
	    this._lex.next (next).rewind ();	
	    if (next == Tokens.LACC || next == Tokens.IMPLIQUE) {
		return visitLambdaEmpty ();
	    }
	    isTuple = true;
	} else {
	    this._lex.rewind ();
	    while (true) {
		params.insertBack (visitExpressionUlt ());
		tok = _lex.next (Tokens.RPAR, Tokens.COMA);
		if (tok == Tokens.RPAR) break;
		else {
		    isTuple = true;
		    next = this._lex.next ();
		    if (next == Tokens.RPAR) break;
		    else this._lex.rewind ();
		}
	    }
	}
		
	if (params.length != 1 || isTuple) exp = new ConstTuple (token, tok, params);
	else exp = params[0];
	
	tok = _lex.next ();
	if (find !"b == a" (_suiteElem, tok) != []) {
	    return visitSuite (tok, exp);
	} else if (find!"b == a" (_afUnary, tok) != []) {
	    return visitAfter (tok, exp);
	} else _lex.rewind ();
	return exp;
    }

    private Expression visitConstante () {       
	auto tok = this._lex.next ();
	if (tok.isEof ()) return null;
	if (tok.str [0] >= '0'&& tok.str [0] <= '9')
	    return visitNumeric (tok);
	else if (tok == Tokens.DOT)
	    return visitFloat (tok);
	else if (tok == Tokens.APOS || tok == Tokens.GUILL || tok == Tokens.BSTRING)
	    return visitString (tok);
	else if (tok == Keys.TRUE || tok == Keys.FALSE)
	    return new Bool (tok);
	else if (tok == Keys.NULL)
	    return new Null (tok);
	else if (tok == Keys.EXPAND)
	    return visitExpand ();
	else if (tok == Keys.IS) 
	    return visitIs ();
	else if (tok == Keys.TYPEOF)
	    return visitTypeOf ();
	else _lex.rewind ();
	return null;
    }
    
    private Expression visitExpand () {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto next = this._lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	auto expr = visitExpression ();
	next = this._lex.next ();
	if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	return new Expand (begin, expr);
    }

    private Expression visitTypeOf () {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto next = this._lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	auto expr = visitExpression ();
	next = this._lex.next ();
	if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	return new TypeOf (begin, expr);
    }
    
    private Expression visitIs () {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto next = this._lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	this._lambdaPossible = false;
	auto expr = visitExpression ();
	this._lambdaPossible = true;
	next = this._lex.next ();
	if (next != Tokens.COLON) throw new SyntaxError (next, [Tokens.COLON.descr]);
	next = this._lex.next ();
	if (next == Keys.FUNCTION || next == Keys.STRUCT || next == Keys.TUPLE) {
	    auto expType = next;
	    next = this._lex.next ();
	    if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	    return new Is (begin, expr, expType);
	} else {
	    this._lex.rewind ();
	    auto type = visitType ();
	    next = this._lex.next ();
	    if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	    return new Is (begin, expr, type);
	}
    }
    
    private Expression visitNumeric (Word begin) {
	foreach (it ; 0 .. begin.str.length) {
	    if (begin.str [it] < '0' || begin.str [it] > '9') {		
		if (begin.str [it .. $] == "ub" || begin.str [it .. $] == "UB") return new Decimal (Word (begin.locus, begin.str [0 .. it]), DecimalConst.UBYTE);
		else if (begin.str [it .. $] == "b" || begin.str [it .. $] == "B") return new Decimal (Word (begin.locus, begin.str [0 .. it]), DecimalConst.BYTE);
		else if (begin.str [it .. $] == "s" || begin.str [it .. $] == "S") return new Decimal (Word (begin.locus, begin.str [0 .. it]), DecimalConst.SHORT);
		else if (begin.str [it .. $] == "us" || begin.str [it .. $] == "US") return new Decimal (Word (begin.locus, begin.str [0 .. it]), DecimalConst.USHORT);
		else if (begin.str [it .. $] == "u" || begin.str [it .. $] == "U") return new Decimal (Word (begin.locus, begin.str [0 .. it]), DecimalConst.UINT);
		else if (begin.str [it .. $] == "ul" || begin.str [it .. $] == "UL") return new Decimal (Word (begin.locus, begin.str [0 .. it]), DecimalConst.ULONG);
		else if (begin.str [it .. $] == "l" || begin.str [it .. $] == "L") return new Decimal (Word (begin.locus, begin.str [0 .. it]), DecimalConst.LONG);
		else throw new SyntaxError (begin);
	    }
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
	return new Decimal (begin, DecimalConst.INT);
    }    

    private Expression visitFloat (Word begin) {
	auto next = _lex.next ();
	foreach (it ; next.str) {
	    if (it < '0' || it > '9')
		throw new SyntaxError (next);	    
	}
	return new Float (next);
    }
    


    private short fromHexa (string elem) {
	short total = 0;
	ulong size = elem.length - 1;
	foreach (it ; elem [0 .. $]) {
	    if (it >= 'a') {
		total += pow (16, size) * (it - 'a' + 10);
	    } else
		total += pow (16, size) * (it - '0');
	    size -= 1;
	}
	return total;
    }

    private short fromOctal (string elem) {
	short total = 0;
	ulong size = elem.length - 1;
	foreach (it ; elem [0 .. $]) {
		total += pow (8, size) * (it - '0');
	    size -= 1;
	}
	return total;
    }

    private short getFromLX (string elem) {
	foreach (it ; elem [2 .. $])
	    if ((it < 'a' || it > 'f') && (it < '0' || it > '9'))
		return -1;
	auto escape = elem [2 .. $];
	return fromHexa (escape);
    }

    private short getFromOc (string elem) {
	foreach (it ; elem [1 .. $])
	    if (it < '0' || it > '7') return -1;
	auto escape = elem [1 .. $];	
	return fromOctal (escape);
    }    
        
    private short isChar (string value) {
	auto escape = ["\\a": '\a', "\\b" : '\b', "\\f" : '\f',
		       "\\n" : '\n', "\\r" : '\r', "\\t" : '\t',
		       "\\v" : '\v', "\\" : '\\',  "\'" : '\'',
		       "\"" : '\"', "\?": '\?'];

	if (value.length == 0) return -1;
	if (value.length == 1) return cast(short) (value[0]);
	auto val = (value in escape);
	if (val !is null) return cast(short) *val;
	if (value[0] == Keys.ANTI.descr [0]) {
	    if (value.length == 4 && value[1] == Keys.LX.descr [0]) {
		return getFromLX (value);
	    } else if (value.length > 1 && value.length < 5) {
		return getFromOc (value);
	    }
	}
	return -1;
    }

    private Expression visitString (Word word) {
	_lex.skipEnable (Tokens.SPACE, false);       
	_lex.commentEnable (false);
	if (word == Tokens.BSTRING) {
	    word.str = Tokens.ESTRING.descr;
	    _lex.skipEnable (Tokens.RETOUR, false);
	    _lex.skipEnable (Tokens.RRETOUR, false);
	    _lex.skipEnable (Tokens.TAB, false);
	}
	
	Word next, beg;
	string val = ""; bool anti = false;	
	while (1) {
	    next = _lex.next ();
	    if (next.isEof ()) throw new SyntaxError (next);	    
	    else if (next == word && !anti) break;
	    else val ~= next.str;
	    if (next == Keys.ANTI) anti = true;
	    else anti = false;
	}
	_lex.skipEnable (Tokens.SPACE);
	_lex.skipEnable (Tokens.RETOUR);
	_lex.skipEnable (Tokens.RRETOUR);	
	_lex.skipEnable (Tokens.TAB);
	_lex.commentEnable ();
	if (word == Tokens.APOS) {
	    auto c = isChar (val);
	    if (c >= 0) return new Char (word, cast(ubyte) (c));
	}
	return new String (word, val);
    }


    private Expression visitPthWPar (Word tok) {
	this._lex.rewind ();
	auto constante = visitConstante ();
	if (constante !is null) {
	    tok = this._lex.next ();
	    if (find! ("b == a") (_suiteElem, tok) != []) {
		return visitSuite (tok, constante);
	    } else this._lex.rewind ();
	    return constante;
	}
	auto left = visitLeftOp ();
	tok = _lex.next ();
	if (find ! "b == a" (_afUnary, tok) != []) {
	    return visitAfter (tok, left);
	} else _lex.rewind ();
	return left;
    }

    private Expression visitLeftOp () {
	auto word = this._lex.next ();
	if (word == Keys.CAST) {
	    return visitCast ();
	} else if (word == Tokens.LCRO) {
	    return visitConstArray ();
	} else if (word == Keys.FUNCTION) {
	    return visitFuncPtr ();
	} else if (word == Keys.MIXIN) {
	    return visitMixin ();
	} else  if (word == Keys.MATCH) {
	    return visitMatch ();
	} else this._lex.rewind ();
	auto var = visitVar ();
	auto next = _lex.next ();
	if (find!"b == a" (_suiteElem, next) != []) 
	    return visitSuite (next, var);
	else _lex.rewind ();
	return var;
    }

    private Expression visitConstArray () {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto word = this._lex.next ();
	Array!Expression params;
	if (word != Tokens.RCRO) {
	    this._lex.rewind ();
	    auto fst = visitExpression ();
	    auto next = _lex.next ();
	    if (next == Tokens.SEMI_COLON) {
		auto size = visitExpression ();
		next = _lex.next ();
		if (next != Tokens.RCRO) throw new SyntaxError (next, [Tokens.RCRO.descr]);
		return new ArrayAlloc (begin, fst, size);
	    } else {
		params.insertBack (fst);
		this._lex.rewind ();
		while (true) {
		    word = this._lex.next ();
		    if (word == Tokens.RCRO) break; 
		    else if (word != Tokens.COMA) throw new SyntaxError (word, [Tokens.COMA.descr, Tokens.RCRO.descr]);
		    params.insertBack (visitExpression ());
		}
	    }
	}
	return new ConstArray (begin, params);
    }

        
    /**
     cast := 'cast' ':' type '(' expression ')'
     */
    private Expression visitCast () {
	this._lex.rewind ();
	Expression type;
	auto begin = this._lex.next ();
	auto word = this._lex.next (Tokens.COLON);
	auto next = this._lex.next ();
	if (next == Keys.FUNCTION) {
	    type = visitFuncPtrSimple ();	    
	} else {
	    this._lex.rewind ();
	    type = visitType ();
	}
	word = this._lex.next (Tokens.LPAR);
	auto expr = visitExpression ();
	word = this._lex.next (Tokens.RPAR);
	return new Cast (begin, type, expr);	
    }


    /**
     func := 'function' '(' (var (',' var)*)? ')' '->' var
     */
    private Expression visitFuncPtrSimple () {
	Array!Var params;
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto word = this._lex.next ();
	if (word != Tokens.LPAR) throw new SyntaxError (word, [Tokens.LPAR.descr]);
	word = this._lex.next ();
	if (word != Tokens.RPAR) {
	    this._lex.rewind ();
	    while (true) {
		params.insertBack (visitType ());
		word = this._lex.next ();
		if (word == Tokens.RPAR) break;
		else if (word != Tokens.COMA) throw new SyntaxError (word, [Tokens.COMA.descr, Tokens.RPAR.descr]);		
	    }	    
	}
	word = this._lex.next (Tokens.ARROW);
	auto ret = visitType ();
	return new FuncPtr (begin, params, ret);
    }

    
    /**
     func := 'function' '(' (var (',' var)*)? ')' ':' var
     */
    private Expression visitFuncPtr () {
	Array!Var params;
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto word = this._lex.next ();
	if (word != Tokens.LPAR) throw new SyntaxError (word, [Tokens.LPAR.descr]);
	word = this._lex.next ();
	if (word != Tokens.RPAR) {
	    this._lex.rewind ();
	    while (true) {
		params.insertBack (visitType ());
		word = this._lex.next ();
		if (word == Tokens.RPAR) break;
		else if (word != Tokens.COMA) throw new SyntaxError (word, [Tokens.COMA.descr, Tokens.RPAR.descr]);		
	    }	    
	}
	word = this._lex.next (Tokens.ARROW);
	auto ret = visitType ();
	word = this._lex.next ();
	if (word == Tokens.LPAR) {
	    auto expr = visitExpression ();
	    word = this._lex.next ();
	    if (word != Tokens.RPAR) throw new SyntaxError (word, [Tokens.RPAR.descr]);
	    return new FuncPtr (begin, params, ret, expr);
	} else this._lex.rewind ();
	return new FuncPtr (begin, params, ret);
    }

    private Expression visitLambdaEmpty () {
	auto next = this._lex.next ();
	if (next == Tokens.IMPLIQUE) {
	    auto expr = visitExpressionUlt ();
	    return new LambdaFunc (next, make!(Array!Var), expr);
	} else if (next == Tokens.LACC) {
	    this._lex.rewind ();
	    return new LambdaFunc (next, make!(Array!Var), visitBlock ());
	} else throw new SyntaxError (next, [Tokens.IMPLIQUE.descr, Tokens.LACC.descr]);
    }
    
    private Expression visitLambda () {
	Array!Var params;
	this._lex.rewind ();
	auto begin = this._lex.next ();
	while (true) {
	    params.insertBack (visitTypedVarDeclaration ());
	    auto next = this._lex.next ();
	    if (next == Tokens.RPAR) break;
	    else if (next != Tokens.COMA)
		throw new SyntaxError (next, [Tokens.RPAR.descr, Tokens.COMA.descr]);
	}
	auto next = this._lex.next ();
	if (next == Tokens.IMPLIQUE) {
	    auto expr = visitExpressionUlt ();
	    return new LambdaFunc (begin, params, expr);
	} else if (next == Tokens.LACC) {
	    this._lex.rewind ();
	    auto block = visitBlock ();
	    return new LambdaFunc (begin, params, block);
	} else throw new SyntaxError (next);
    }    
    
    
    private Expression visitSuite (Word token, Expression left) {
	if (token == Tokens.LPAR) return visitPar (left);
	else if (token == Tokens.LCRO) return visitAccess (left);
	else if (token == Tokens.DOT) return visitDot (left);
	else if (token == Tokens.DCOLON) return visitDColon (left);
	else
	    throw new SyntaxError (token);
    }


    /**
     par := '(' (expression (',' expression)*)? ')'
     */
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
	auto retour = new Par (beg, next, left, new ParamList (suite, params));
	next = _lex.next ();
	if (find !"b == a" (_suiteElem, next) != [])
	    return visitSuite (next, retour);
	else if (find!"b == a" (_afUnary, next) != [])
	    return visitAfter (next, retour);
	_lex.rewind ();
	return retour;
    }

    /**
     access := '[' (expression (',' expression)*)? ']'
     */
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
	auto retour = new Access (beg, next, left, new ParamList (suite, params));
	next = _lex.next ();
	if (find !"b == a" (_suiteElem, next) != [])
	    return visitSuite (next, retour);
	else if (find!"b == a" (_afUnary, next) != [])
	    return visitAfter (next, retour);
	_lex.rewind ();
	return retour;
    }
    
    /**
     dot := '.' identifiant
     */
    private Expression visitDot (Expression left) {
	_lex.rewind ();
	auto begin = _lex.next ();
	auto next = this._lex.next ();
	Expression retour;
	if (next == Keys.EXPAND) {
	    retour = new Expand (next, left);
	} else if (next == Keys.TYPEOF) {
	    retour = new TypeOf (next, left);
	} else {
	    this._lex.rewind ();
	    Expression right = visitConstante ();
	    if (right is null) right = visitVar ();
	    retour = new Dot (begin, left, right);
	}
	next = _lex.next ();
	if (find !"b == a" (_suiteElem, next) != [])
	    return visitSuite (next, retour);
	else if (find!"b == a" (_afUnary, next) != [])
	    return visitAfter (next, retour);
	_lex.rewind ();
	return retour;
    }

    /**
       DColon := '::' identifiant
     */
    private Expression visitDColon (Expression left) {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto right = visitVar ();
	auto retour = new DColon (begin, left, right);
	auto next = this._lex.next ();
	if (find (this._suiteElem, next) != [])
	    return visitSuite (next, retour);
	else if (find (this._afUnary, next) != [])
	    return visitAfter (next, retour);
	this._lex.rewind ();
	return retour;
    }
    
    /**
       mixin := 'mixin' expression 
     */
    private Expression visitMixin () {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto expr = visitPth ();
	return new Mixin (begin, expr);
    }

    
    private Expression visitMatch () {
	Array!Expression values;
	Array!(Match.Pair) pairs;
	Array!Block insts;
	Block defaultInsts;
	
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto expr = visitExpression ();
	
	auto next = this._lex.next (Tokens.LACC);
	while (true) {
	    next = this._lex.next ();
	    if (next != Keys.UNDER) {
		this._lex.rewind ();
		values.insertBack (this.visitExpression);
		next = this._lex.next (Tokens.IMPLIQUE, Tokens.TDOT);
		if (next == Tokens.TDOT) {
		    values.back () = new Match.Pair (next, values.back (), this.visitExpression);
		    next = this._lex.next (Tokens.IMPLIQUE);
		}
		
		insts.insertBack (this.visitBlock ());
		next = this._lex.next ();
		if (next == Tokens.RACC) break;
		else this._lex.rewind ();
	    } else {
		this._lex.next (Tokens.IMPLIQUE);
		defaultInsts = this.visitBlock ();
		this._lex.next (Tokens.RACC);
		break;
	    }
	}
	
	return new Match (begin, expr, values, insts, defaultInsts);
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

    private Assert visitAssert () {
	_lex.rewind ();
	auto begin = this._lex.next (), next = this._lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	auto expr = visitExpression ();
	Expression msg;
	next = this._lex.next ();
	if (next == Tokens.COMA) {
	    msg = visitExpression ();
	    next = this._lex.next ();
	} 
	if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	next = this._lex.next ();
	if (next != Tokens.SEMI_COLON) throw new SyntaxError (next, [Tokens.SEMI_COLON.descr]);
	return new Assert (begin, expr, msg);
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
    
    
    private Instruction visitBreak () {
	this._lex.rewind ();
	auto begin = this._lex.next (), next = this._lex.next ();
	if (next == Tokens.SEMI_COLON) {
	    return new Break (begin);
	} else _lex.rewind ();
	auto id = visitIdentifiant ();
	next = this._lex.next ();
	if (next != Tokens.SEMI_COLON)
	    throw new SyntaxError (next, [Tokens.SEMI_COLON.descr]);
	return new Break (begin, id);
    }

    private Instruction visitWhile () {
	_lex.rewind ();
	auto begin = _lex.next ();
	auto next = this._lex.next ();
	if (next == Tokens.COLON) {
	    auto id = visitIdentifiant ();
	    next = this._lex.next ();
	    if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	    auto test = visitExpression ();
	    next = this._lex.next ();
	    if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	    return new While (begin, id, test, visitBlock ());
	} else {
	    this._lex.rewind ();
	    auto test = visitExpression ();
	    return new While (begin, test, visitBlock ());
	}
    }

    private Instruction visitFor () {
	this._lex.rewind ();
	auto begin = this._lex.next ();
	auto next = this._lex.next ();
	Word id = Word.eof;
	bool need = false;
	if (next == Tokens.COLON) {
	    id = visitIdentifiant ();
	    next = this._lex.next ();
	    if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	    need = true;
	} else if (next == Tokens.LPAR) {
	    need = true;
	} else this._lex.rewind ();
	Array!Var vars;
	while (true) {	    
	    vars.insertBack (visitVar ());
	    next = this._lex.next ();
	    if (next == Keys.IN) break;
	    if (next != Tokens.COMA) throw new SyntaxError (next, [Keys.IN.descr,
								   Tokens.COMA.descr]);
	}

	auto iter = visitExpression ();
	if (need) {
	    next = this._lex.next ();
	    if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	}

	return new For (begin, id, vars, iter, visitBlock ());
    }
    
    
}
