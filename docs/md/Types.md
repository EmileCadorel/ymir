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
Ymir intérdit la perte de précision implicite, on ne peut affecter (sans cast) que des types de taille inférieur vers supérieur.

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
Les propriétées des types décimaux sont les suivantes: 
- **init**, la variable d'initialisation d'un int (0)
- **max**, la valeur max d'un int
- **min**, la valeur min d'un int (pas 0)
- **sizeof**, la taille en mémoire d'un int (en octet)
- **typeid**, le type sous forme de chaine


<br>
### Types à virgule flottante
---------------

Les floats et les doubles sont les deux types à virgule flottantes.
Comme pour les entiers, on ne peut passer d'un double à un float sans cast.
(Les floats ne sont pas encore gérés).    

```D
let a = 8., b = .78, c = 8.7f; 
c = a; // Erreur, c:float, a:double
c = cast:float (a); // Ok
a = c; // Ok

```

<br>
Les propriétées des types flottants sont les suivantes:
    
- **init**, 0.0f
- **max**, la valeur maximal d'un nombre flottant.
- **min**, la valeur minimal d'un nombre flottant
- **nan**, la valeur Not a Number flottante (0. / 0.);
- **dig**, le nombre de chiffre décimaux de précision.
- **epsilon**, le plus petit incrément possible à la valeur 1.
- **mant_dig**, le nombre de bits dans la mantis.
- **max_10_exp**, la valeur la plus grande tel que 10^max_10_exp est représentable
- **max_exp**, la valeur maximum tel que 2^max_exp est représentable.
- **min_10_exp**, la valeur minimal tel que 10^min_10_exp est représentable.
- **min_exp**, la valeur minimal tel que 2^min_exp est représentable.
- **infinity**, la valeur qui représente l'infini en nombre flottant.
- **typeid**, le type sous forme de chaine.
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
     
