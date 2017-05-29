# Ymir
 <hr>

Ymir est un langage haut niveau inspiré par D, python, Rust et OCaml.
Il compile un ensemble de modules en fichiers objets qui sont ensuite envoyés dans un éditeur de liens, afin de générer un exécutable natif. 

## Compilation
------------

La compilation est séparée en plusieurs phases.
* **Analyse syntaxique :**

 Cette phase génère l'arbre de syntaxe, et vérifie la cohérence grammaticale du code

* **Analyse sémantique :**

 L'arbre de syntaxe est parcouru afin de déclarer les symboles, vérifier la cohérence des types.

* **Génération de code intermédiaire :**

 Le langage intermédiaire est un langage de bas niveau, c'est la dernière partie qui ne va pas dépendre de l'architecture visée par le compilateur

* **Génération du code de la cible :**

 Le langage intermédiaire est transformé en fichier objet, puis sont envoyé à l'éditeur de lien (pour le moment gcc).


## Programme
--------------

Un programme Ymir doit contenir un point d'entrée - la fonction `main`.

La fonction `main` est une fonction pure par définition.


```
def main () {
}
```
 ou 
```
def main (params) { // params est un array!string
}

```
Par défaut, la fonction `main` renvoie la valeur 0.

