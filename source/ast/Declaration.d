module ast.Declaration;

/**
 Ancêtre de toutes les déclarations.
 */
class Declaration {

    /**
     Fonction à surcharger pour se déclarer dans la table des symboles.
     */
    abstract void declare ();

    /**
     Fonction à surcharger pour se déclarer dans la table des symboles comme données externes.
     */
    void declareAsExtern () {}
    
    /**
     Fonction à surcharger pour l'affichage
     */
    void print (int nb = 0) {}
}
