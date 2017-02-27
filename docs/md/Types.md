# Variables
 <hr>

Le type des variables est inféré dans tous les cas.

```D
//...
let a = 10, b = 'salut'; // a est de type _int_, b de type _string_
let c; // c est de type non définis, il ne peut être utilisé avant d'être affecté.

a = c + 10; // Erreur c n'est pas initialisé.
c = a + 10; // Ok, c est de type _int_
c = b; // Erreur, pas d'operateur '=' entre (int) et (string).

```

<br>
## Type primitif
-----------------

Les types primitifs ont des propriétés qui peuvent être récupérées à partir du type ou d'expression du même type.
```D
// ...
let a = long.max;
let b = ('r').typeid;
```


<br>
### Types à virgule fixe
----------------------

Les types décimaux sont regroupés en deux catégories, signés et non signés.
Un système de promotions est utilisé pour connaître les conversions implicites.
Ymir interdit la perte de précision implicite, on ne peut affecter (sans cast) que des types de taille inférieure vers supérieur.

```D
let a = 10; // a est de type int.
let b = 1l; // b est de type long.

a = b; // Erreur 
b = a; // Ok

```

<br>
Il est aussi impossible de transformer un signé vers un non signé et inversement.

```D
let a = 1u; // a est de type uint
let b = 1; // b est de type int

a = b; // Erreur
b = a; // Erreur

a = cast:uint (b); // Ok

```

<br>
Les propriétés des types décimaux sont les suivantes : 
- **init**, la variable d'initialisation d'un int (0)
- **max**, la valeur max d'un int
- **min**, la valeur min d'un int (pas 0)
- **sizeof**, la taille en mémoire d'un int (en octet)
- **typeid**, le type sous forme de chaîne


<br>
### Types à virgule flottante
---------------

Les floats et les doubles sont les deux types à virgule flottante.
Comme pour les entiers, on ne peut passer d'un double à un float sans cast.
(Les floats ne sont pas encore gérés).    

```D
let a = 8., b = .78, c = 8.7f; 
c = a; // Erreur, c:float, a:double
c = cast:float (a); // Ok
a = c; // Ok

```

<br>
Les propriétés des types flottants sont les suivantes :
    
- **init**, 0.0f
- **max**, la valeur maximale d'un nombre flottant.
- **min**, la valeur minimale d'un nombre flottant
- **nan**, la valeur '_Not a Number_' flottante (0. / 0.);
- **dig**, le nombre de chiffres décimaux de précision.
- **epsilon**, le plus petit incrément possible à la valeur 1.
- **mant_dig**, le nombre de bits dans la mantis.
- **max_10_exp**, la valeur la plus grande tel que 10^max_10_exp est représentable
- **max_exp**, la valeur maximum tel que 2^max_exp est représentable.
- **min_10_exp**, la valeur minimal tel que 10^min_10_exp est représentable.
- **min_exp**, la valeur minimal tel que 2^min_exp est représentable.
- **infinity**, la valeur qui représente l'infini en nombre flottant.
- **typeid**, le type sous forme de chaîne.
- **sqrt**, la racine carré du float (_float.sqrt_ => 0.)

<br>
 ### Range
-----------

Le type range est un type particulier, il prend un type en templates (un type décimal, flottant ou _char_).
Il s'obtient avec la syntaxe 

```D
let a = 0 .. 8;
```

et possède deux propriétés :
 - **fst**, le premier élément du range
 - **scd**, le second élément du range

 
Le type range est un type itérable.

```D
let a = 10 .. -1;
for (it in a) print (it); // 109876543210
```
     

<br>
### Tuple
-------------

Le type tuple est un type standard du langage Ymir. Il est utilisé de façon implicite lors de l'appel de fonction variadic, mais peut être instancié autrement.

```D
let a = (1, 2, 'salut'); // a est de type 'tuple!(int, int, string).

```
<br>
Contrairement à d'autres langages (comme python), il est impossible de déclarer un tuple ne possédant aucune ou une seule valeur.
```D
let a = (1); // a est de type int;
let b = (); //Erreur
```

<br>
On peut aussi spécialiser les fonctions pour qu'elle l'accepte en paramètre.

```D
def foo (t : tuple!(int, char)) {
    println (expand (t));
}

//...

let a = (1, 'r');
foo (a);

foo ((3, 't'));

```

Comme pour tous les types de haut niveau du langage Ymir (tableau, range, structure, ...), le tuple n'est alloué qu'une seule fois et les variables possède un référence vers cette allocation.
    
