module ymir.ast.If;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.stdio, std.string;
import std.container;


/**
 Classe généré par la syntaxe 
 Example:
 ----
 if (expression) block
 (else)?
 ----

*/

class If : Instruction {

    /// L'expression de test, pour savoir si on execute le bloc ou non
    private Expression _test;

    /// Le block a executer si le test est vrai
    private Block _block;

    /// Le block else (peut être null)
    private Else _else;

    /// Le type de l'expression (sert pour le cast en bool si besoin)
    private InfoType _info;
    
    this (Word word, Expression test, Block block, bool isStatic = false) {
	super (word);
	this._test = test;
	this._test.inside = this;
	this._block = block;
	this._isStatic = isStatic;	
    }

    this (Word word, Expression test, Block block, Else else_, bool isStatic = false) {
	super (word);
	this._test = test;
	this._test.inside = this;
	this._block = block;
	this._else = else_;
	this._isStatic = isStatic;
	if (this._else)
	    this._else.isStatic = isStatic;
    }

    override bool isStatic () {
	return this._isStatic;
    }

    override void isStatic (bool isStatic) {
	this._isStatic = isStatic;
	if (this._else)
	    this._else.isStatic = isStatic;
    }

    
    /**
     * Met a jour le pere de l'instruction.
     * Params:
     *       father = le block qui contient l'instruction 'if'
     */
    override void father (Block father) {
	super._block = father;
	this._block.father = father;
	if (this._else)
	    this._else.father = father;
    }

    /**
     Verification sémantique de l'instruction.
     Pour être juste l'instruction doit contenir un test compatible avec le type 'bool'.
     Throws: IncompatibleTypes, si l'expression n'est pas compatible
     */
    override Instruction instruction () {
	auto expr = this._test.expression;
	auto type = expr.info.type.CastOp (new BoolInfo ());
	auto word = this._token;
	word.str = "cast";
	if (type is null)
	    throw new IncompatibleTypes (expr.info, new Symbol (word, new BoolInfo ()));

	bool pass = false;
	if (this._isStatic) {
	    if (!expr.info.isImmutable) throw new NotImmutable (expr.info);
	    else if ((cast(BoolValue) (expr.info.value)).isTrue) {
		return this._block.instruction ();
	    } else {
		if (this._else)
		    return this._else.instruction ();
		else return new Block (this._block.token, make!(Array!Declaration), make!(Array!Instruction));
	    }
	}
	
	Table.instance.retInfo.currentBlock = "if";
	Table.instance.retInfo.changed = true;
	Block bl = this._block.instructions ();
	
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

    override Instruction templateReplace (Expression [string] values) {
	auto test = this._test.templateExpReplace (values);
	auto block = this._block.templateReplace (values);
	if (this._else) {
	    auto else_ = cast (Else) this._else.templateReplace (values);
	    return new If (this._token, test, block, else_, this._isStatic);
	}
	return new If (this._token, test, block, this._isStatic);
    }
    
    /**
     Returns: le test de l'instruction
     */
    Expression test () {
	return this._test;
    }

    /**
     Returns: le caster de l'instruction 
     */
    InfoType info () {
	return this._info;
    }

    /**
     Returns: Le block a éxecuter si l'expression est évalué à vrai
     */
    Block block () {
	return this._block;
    }

    /**
     Returns: l'instruction 'else' du 'if' (peut être null)
     */
    Else else_ () {
	return this._else;
    }

    /**
     * Affiche l'instruction If sous forme d'arbre
     * Params:
     *        nb = l'offset courant
     */
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


/**
 Classe genere par la syntaxe 
 Example:
 ----
 (if (test) block)
 else // <- 
 ----

 */
class Else : Instruction {
    
    /// Le block à éxecuter si on se trouve dans le 'else'
    private Block _block;

    ///
    this (Word word, Block block) {
	super (word);
	this._block = block;
    }

    /**
     * Met a jour le pere de l'instruction.
     * Params:
     *       father = le block qui contient l'instruction 'else'
     */
    override void father (Block father) {
	super._block = father;
	this._block.father = father;
    }
    
    /**
     Vérification sémantique.
     Pour être juste toutes les instructions du block doivent être juste     
     */
    override Instruction instruction () {
	if (this._isStatic) return this._block.instructions ();
	Table.instance.retInfo.currentBlock = "else";
	Table.instance.retInfo.changed = true;
	auto aux = new Else (this._token, this._block.instructions);
	return aux;
    }

    override Else templateReplace (Expression [string] values) {
	return new Else (this._token, this._block.templateReplace (values));
    }
    
    /**
     Le block contenu dans le else
     */
    Block block () {
	return this._block;
    }
    
    /**
     Affiche l'instruction sour forme d'arbre
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Else> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._block.print (nb + 4);	
    }
    
}


/**
 Classe genere par la syntaxe
 Example:
 ----
 if (test) block
 else if (test) block // <-
 (else)?
 ----
 */
class ElseIf : Else {

    /// Le test pour entre dans la condition
    private Expression _test;

    /// Le block else (peut être null)
    private Else _else;

    /// Le caster de l'expression, (peut être null)
    private InfoType _info;
    
    this (Word word, Expression test, Block block, bool isStatic = false) {
	super (word, block);
	this._test = test;
	this._test.inside = this;
	this._isStatic = isStatic;
    }

    this (Word word, Expression test, Block block, Else else_, bool isStatic = false) {
	super (word, block);
	this._test = test;
	this._test.inside = this;
	this._else = else_;
	this._isStatic = isStatic;
    }

    override void isStatic (bool isStatic) {
	this._isStatic = isStatic;
	if (this._else)
	    this._else.isStatic = isStatic;
    }
    
    /**
     * Met a jour le pere de l'instruction.
     * Params:
     *       father = le block qui contient l'instruction 'else'
     */
    override void father (Block father) {
	super.setFatherBlock (father);
	this._block.father = father;
	if (this._else)
	    this._else.father = father;
    }

    /**
     Verification sémantique de l'instruction
     Pour être juste le test doit être compatible avec le type 'bool'.
     Et toutes les instructions du block doivent être juste
     Throws : IncompatibleTypes, si le test n'est pas compatible avec 'bool'
     */
    override Instruction instruction () {
	auto expr = this._test.expression;
	auto type = expr.info.type.CastOp (new BoolInfo ());
	if (type is null)
	    throw new IncompatibleTypes (expr.info, new BoolInfo ());

	bool pass = false;
	if (this._isStatic) {
	    if (!expr.info.isImmutable) throw new NotImmutable (expr.info);
	    else if ((cast(BoolValue) (expr.info.value)).isTrue) {
		return this._block.instructions ();
	    } else {
		if (this._else)
		    return this._else.instruction ();
		else return new Block (this._block.token, make!(Array!Declaration), make!(Array!Instruction));
	    }
	}


	Table.instance.retInfo.currentBlock = "if";
	
	Block bl = this._block.instructions ();
	ElseIf _if;
	if (this._else !is null) {
	    _if = new ElseIf (this._token, expr, bl, cast(Else) this._else.instruction (), this._isStatic);
	    _if._info = type;
	} else {
	    _if = new ElseIf (this._token, expr, bl, this._isStatic);
	    _if._info = type;
	}
	return _if;
    }
    
    override Else templateReplace (Expression [string] values) {
	auto test = this._test.templateExpReplace (values);
	auto block = this._block.templateReplace (values);
	if (this._else) {
	    auto else_ = this._else.templateReplace (values);
	    return new ElseIf (this._token, test, block, else_, this._isStatic);
	}
	return new ElseIf (this._token, test, block, this._isStatic);
    }

    /**
     Returns: Le test de l'instruction
     */
    Expression test () {
	return this._test;
    }

    /**
     Returns: Le 'else' de l'instruction (peut être null)
     */
    Else else_ () {
	return this._else;
    }

    /**
     Returns: Le caster du test (peut être null)
     */
    InfoType info () {
	return this._info;
    }
    
    /**
     * Affiche l'instruction sous forme d'arbre.
     * Params:
     *       nb = L'offset courant
     */
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
