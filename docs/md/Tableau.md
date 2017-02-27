# Tableau
 <hr>
Ymir permet l'utilisation de tableau dynamique directement dans le langage sans importation de bibliothèque. 
Les tableaux sont libérés par le garbage collector lorsqu'il n'y a plus de référence sur eux.
<br>
## Déclaration
--------------

Les tableaux se créent de la façon suivante :

```D
let a1 = [1, 2, 3]; // array!int
let a2 = [1., 2.]; // array!float
let b = [[1, 2], [3, 4]]; // array!(array!int)
let c = ["salut", 'ca va ?']; // array!string
let d = ["salut", [1, 2]]; // Erreur, type incompatible (string) et (array!int)
```
<br>
On peut déclarer un tableau alloué dynamiquement à partir d'une taille

```D
let a = [int; 1024u]; // Tableau de int de taille 1024
a += [90, 67];

a = [int; a.length - 89u]; // reallocation du tableau avec une nouvelle taille.

```

<br>
Les tableaux peuvent être passés en paramètre de fonction, mais uniquement par référence.

```D
def foo (a : [string]) {
   a [0] = 'Oui !!';
   a = ["Non '-_-"];
}

// ...
let a = ['Ca marche ?'];
println (a [0]); // Ok, 'Ca marche ?';
foo (a);
println (a [0]); // Ok, 'Oui !!'
```

<br>
## Cast
----------

Dans le langage Ymir, il n'existe aucune différence entre un _string_ et un _array!char_. Ces deux types ne sont différenciés que pour permettre une spécialisation de template lors de l'analyse sémantique.
Ainsi, il est tout à fait possible de passer de l'un à l'autre.


``` D
let a = 'Salut';
println (a); // Ok, 'Salut'
println (cast:array!(char) (a)); // Ok, '[S, a, l, u, t]'
// ou cast:[char] (a);
let b = cast:string (['a', 'b', 'c']);

```

<br>
## Opérateur
-------------

Comme pour les _string_ les tableaux surchargent l'opérateur _+_

```D
let a = [1] + [2];
a += [1, 2, 3]; 
println (a); // '[1, 2, 1, 2, 3]'
```

