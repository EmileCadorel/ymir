module ast.Declaration;
import std.container;
import ast.Var, ast.Expression;

/**
 Ancêtre de toutes les déclarations.
 */
class Declaration {

    protected bool _isPublic;
    
    Declaration templateReplace (Array!Var, Array!Expression) {
	assert (false, "TODO");
    }

    /**
     Fonction à surcharger pour se déclarer dans la table des symboles.
     */
    abstract void declare ();

    /**
     Fonction à surcharger pour se déclarer dans la table des symboles comme données externes.
     */
    void declareAsExtern () {}

    /**
     Returns: la declaration est publique.
     */
    bool isPublic () {
	return this._isPublic;
    }

    /**
     Set la déclaration à public ?
     */
    void isPublic (bool pub) {
	this._isPublic = pub;
    }
    
    /**
     Fonction à surcharger pour l'affichage
     */
    void print (int nb = 0) {}
}
