module ast.While;
import ast.Instruction, ast.Expression;
import ast.Block, syntax.Word, semantic.pack.Symbol;
import semantic.types.BoolInfo, semantic.types.InfoType;
import utils.exception, semantic.pack.Table;
import std.stdio, std.string;
import std.container;
import ast.Var;

/**
 Classe généré à la syntaxe par.
 Example:
 ---
 'while' expression block
 ---
 */
class While : Instruction {

    /// L'identifiant de la boucle
    private Word _name;

    /// le test de la boucle
    private Expression _test;

    /// Le block de la boucle
    private Block _block;

    /// Le caster du test (renseigné à la sémantique)
    private InfoType _info;

    this (Word word, Word name, Expression test, Block block) {
	super (word);
	this._name = name;
	this._test = test;
	this._block = block;
    }
    
    this (Word word, Expression test, Block block) {
	super (word);
	this._test = test;
	this._block = block;
	this._name.setEof ();
    }

    /**
     Met à jour le père de la boucle
     Params: 
     father = le block qui contient l'instruction
     */
    override void father (Block father) {
	super._block = father;
	this._block.father = father;
    }

    /**
     Vérification sémantique.
     Pour être juste le test doit être compatible avec 'bool' (CompOp)
     Throws: IncompatibleTypes
     */
    override Instruction instruction () {
	auto expr = this._test.expression;
	auto type = expr.info.type.CastOp (new BoolInfo ());
	auto word = this._token;
	word.str = "cast";
	if (type is null) throw new IncompatibleTypes (expr.info, new Symbol (word, new BoolInfo ()));
	if (!this._name.isEof ())
	    this._block.setIdent (this._name);
	Table.instance.retInfo.currentBlock = "while";
	auto bl = this._block.block;
	auto _while = new While (this._token, expr, bl);
	_while._info = type;
	return _while;
    }

    override While templateReplace (Array!Expression names, Array!Expression values) {
	auto test = this._test.templateExpReplace (names, values);
	auto block = this._block.templateReplace (names, values);
	return new While (this._token, test, block);
    }
    
    /**
     Returns: le test de la boucle
     */
    Expression test () {
	return this._test;
    }

    /**
     Returns: le caster du test
     */
    InfoType info () {
	return this._info;
    }

    /**
     Returns: le block de la boucle
     */
    Block block () {
	return this._block;
    }

    /**
     Affiche l'instruction sous forme d'arbre
     Params:
     nb = l'offset courant
     */
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
