module ast.Return;
import ast.Instruction;
import ast.Expression, syntax.Word;
import semantic.types.UndefInfo, semantic.pack.Table;
import std.stdio, std.string, utils.exception;
import semantic.types.VoidInfo, semantic.types.InfoType;
import lint.LInstList;
import semantic.pack.Symbol;
import ast.Var, std.container;

/**
 L'instruction est généré à la syntaxe par.
 Example:
 ---
 'return' (expression)? ';'
 ---
*/
class Return : Instruction {

    /// L'élément à retourner (peut être null)
    private Expression _elem; 

     /// L'information de cast du type à retourner (peut être null)
    private Symbol _instCast;

    /// l'information de pre-traitement avant de retourner l'instruction (peut être null)
    private InfoType _instComp; 
    
    this (Word word) {
	super (word);
    }
    
    this (Word word, Expression elem) {
	super (word);
	this._elem = elem;
    }

    /**
     Vérification sémantique.
     Pour être juste soit l'instruction doit être du type de la fonction courante.
     Soit 'void' et _elem est null.
     Throws: 
     IncompatibleTypes, si les types ne sont pas compatibles.
     NoValueNonVoidFunction, si on ne retourne rien dans une fonction non-void.
     */
    override Instruction instruction () {
	auto aux = new Return (this._token);
	Table.instance.retInfo.returned ();
	aux._instCast = Table.instance.retInfo.info;		
	if (this._elem !is null) {
	    aux._elem = this._elem.expression ();
	    aux._instComp = aux._elem.info.type.ReturnOp ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = aux._elem.info.type.clone ();
	    } else {
		auto type = aux._elem.info.type.CompOp (Table.instance.retInfo.info.type);
		if (!type) 
		    throw new IncompatibleTypes (aux._elem.info,
						 Table.instance.retInfo.info);
		
		else if (type.isSame (aux._elem.info.type)) {
		    Table.instance.retInfo.info.type = type;		    
		} 
	    }
	} else {
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) is null &&
		cast(VoidInfo) (Table.instance.retInfo.info.type) is null) {
		throw new NoValueNonVoidFunction (this._token);
	    } else {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }
	}
	return aux;
    }
    
    override Instruction templateReplace (Array!Var names, Array!Expression values) {
	if (this._elem is null) return this;
	else return new Return (this._token, this._elem.templateExpReplace (names, values));
    }
    
    
    /**
     Returns: l'element retourner par l'instruction (peut être null)
     */
    Expression elem () {
	return this._elem;
    }
    
    /**
     Returns: le pre-traitement de l'instruction (peut-être null)
     */
    InfoType instComp () {
	return this._instComp;
    }

    /**
     Returns: le caster de l'expression (peut être null)
     */
    Symbol instCast () {
	return this._instCast;
    }

    /**
     Affiche l'instruction sous forme d'arbre
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Return> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	if (this._elem !is null) {
	    this._elem.print (nb + 4);
	}
    }
    
}
