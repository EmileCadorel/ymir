# Ymir

Ymir est un langage haut niveau inspiré par D, python et OCaml.
Il compile un ensemble de modules en fichiers objets qui sont ensuite envoyé dans un linker afin de générer un exécutable natif. 

## Compilation

La compilation est séparée en plusieurs phases.
* **Analyse syntaxique :**

 Cette phase génère l'arbre de syntaxe, et vérifie la cohérence grammatical du code

* **Analyse sémantique :**

 L'arbre de syntaxe est parcouru afin de déclarer les symboles, verifier la cohérence des types.

* **Génération de code intermédiaire :**

 Le langage intermédiaire est un langage de bas niveau, c'est la dernière partie qui ne va pas dépendre de l'architecture visé par le compilateur

* **Génération du code de la cible :**

 Le langage intermédiaire est transformer en fichier objet, puis sont envoyé à l'éditeur de lien (pour le moment gcc).


## Programme

Un programme Ymir doit contenir un point d'entrée - la fonction _main_.

la fonction _main_ est une fonction pure par définition.


```D
def main () {
}
```
 ou 
```D
def main (params) { // params est un array!string
}

```
Par défaut la fonction _main_ renvoie la valeur 0.

