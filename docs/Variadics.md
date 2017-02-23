Ymir proposent un système d'appel de fonction à nombre de paramètre arbitraire. Cette solution est appelé Variadics. Cette solution est fortement lié au tuples. 

Pour le moment il n'existe aucune syntaxe particulière pour spécifié que le fonction est variadics. On déclare une fonction impure dont le dernier arguments n'a pas de type. Lors de l'appel la liste de paramètre va être généré en fonction des paramètres passé à la fonction.

```D
def foo (a) {
 // ...
}

//...
foo (1, 'i', "salut"); (on appel foo avec le type (tuple!(int, char, string)).

```

Le type 'tuple' n'est pas un type itérable, mais on peut récupérer ses attributs de manière récursive.
Le mot clé 'expand' va nous permettre de passer les attributs d'un tuple comme des paramètres de fonctions.

```D
def foo (count, a) {
    print (a.typeid, '(', a, ':', count, ') ');
}

def foo (count : int, a, b) {
    print (a.typeid, '(', a, ':',  count, ') ');
    foo (count + 1, expand (b)); // on transforme b en paramètre 
}

//...
foo (0, 1, 'r', "salut"); // Ok, 'int(1:0) char(r:1) string(salut:2)';



``` 


