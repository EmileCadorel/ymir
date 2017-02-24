
# Ymir

Ymir est un langage haut niveau inspiré par D, python et OCaml.
Il compile un ensemble de modules en fichiers objets qui sont ensuite envoyé dans un linker afin de générer un exécutable natif. 

<br>
## Compilation
---------------
La compilation est séparée en plusieurs phases.
* **Analyse syntaxique :**

 Cette phase génère l'arbre de syntaxe, et vérifie la cohérence grammatical du code

* **Analyse sémantique :**

 L'arbre de syntaxe est parcouru afin de déclarer les symboles, verifier la cohérence des types.

* **Génération de code intermédiaire :**

 Le langage intermédiaire est un langage de bas niveau, c'est la dernière partie qui ne va pas dépendre de l'architecture visé par le compilateur

* **Génération du code de la cible :**

 Le langage intermédiaire est transformer en fichier objet, puis sont envoyé à l'éditeur de lien (pour le moment gcc).

<br>
## Programme
--------------

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

<br>
## Boucles
-------------
 Ymir propose deux types de boucles :
 * Les boucles _While_
 * Les boucles _For_

<br>
### While
-------------
 _While_ boucle jusqu'à ce que la condition soit fausse.

```D
let i = 0;
while i < 101 {
  if i % 2 == 0
     println ('Pair');
  else 
     println ('Impair');
}

```

<br>
### For
---------
 La boucle _For_ itère sur un type itérable.
 Les types itérables sont :
  - string
  - array!T
  - range

```D
for it in [1, 2, 3, 4, 5]
  print (it);

//'12345'
```

 Les _Ranges_ sont des types créés pour pouvoir itérer sur un intervalle.
 
```D
for it in 0 .. 6
   print (it); // '12345'

for it in 6 .. 0
  print (it); // '654321'
```


<br>
## Fonctions
---------------
Les fonctions peuvent être déclarées sous trois formes.
- **Les fonctions pure :**

 Les fonctions pures sont des fonctions qui vont être compilées même si elles ne sont jamais appelées.
 Les types des variables ne sont pas inférés, mais sont écris explicitement.
 
 ```D
    def foo (a : int, b : int) {
     // ...
    }

    def foo2 () : int {
     // ...
    }
  ```

  Le type de retour des fonctions pures est optionnel, il sera déduit lors de la compilation.

- **Les fonctions impures :**

 Les fonctions impures se différencient des fonctions pures au niveau de leurs paramètres.
 Leurs types vont être inféré au moment de leurs appels.
 
  ```D
   def foo (a, b : int, c) { // a et c n'ont pas de type
     // ...
   } 

   // ...
   foo (10, 2, "salut"); // OK, avec a : int et c : string
   foo (10, 'salut', 1); // Erreur, b doit etre de type int
   ```
   Comme pour les fonctions pures, il n'est pas obligatoire de mettre le type de retour qui va être déduit.
 
   Les fonctions impures peuvent être utilisées pour des appels au nombre de paramètres variable (variadics).
   Un tuple est créé pour le dernier type, si il est non typé.

```D
   def test (a : int, b) {
       println (b.typeid);
   }

   def test (a, b : int) {
      println (a.typeid);
   }

   // ...
   test (1, 'r', 'salut'); // Ok, '(char, string)'.
   test (1); // Erreur, pas de surcharge de test applicable.
   test ('salut', 2, 3); // Erreur, On n'utilise pas la deuxieme surcharge 'b' est typé.

```


- **Les fonctions externes :**

 Les fonctions externes sont des fonctions qui n'ont pas de code, leur code doit être fourni au moment de l'édition des liens.
 Ces fonctions doivent être déclarées avec leurs types, ainsi que leur type de retour qui ne peut être déduit.

  ```D
   extern foo (a : int) : double;
   extern (C) putchar (c : char); // le type de retour n'est pas donné, _void_ par défaut.
    // ...
   let b = foo (10);
   putchar ('Y'); 
   ```
Elles peuvent également être déclarées comme variadic.

    ```D
    extern (C) printf (a : ptr!char, ...)
    
    // ...
    printf (('salut %s, comment va tu ?').ptr, nom.ptr);
    ```


 Les fonctions externes ne sont pas importées par défaut. Pour les importer il faut les déclarer comme publiques.

 ```D
 public extern (C) putchar (c : char);
 ```

<br>
## Cas particuliers.
---------------------
 - Récursivité.

 Pour les fonctions récursives, il est obligatoire de mettre le type de retour de la fonction, s'il n'est pas déduit avant son appel.

 ``` D
  def fibo (n : int) {
     if (n < 2) return n; // n est de type _int_, le type de la fonction est _int_
     else return fibo (n - 1) + fibo (n - 2); // pas de problème le type de fibo a été déduit
  }

  def facto (n : int) {
    if (n >= 1) return facto (n - 1) * n; // Erreur, on ne connaît pas le type de facto
    else return 1;
  }
 ```
 - Import

 Les fonctions pures importées qui ne contiennent pas de type de retour, seront considérées comme des fonctions externes void.

<br>
## Surcharge
------------------

Les fonctions peuvent être surchargées qu'elle soit pure ou non.
```D
def foo (a : int, b) {
// ...
}

def foo (a, b : int) {
// ...
}

//...
foo (10, 'salut'); // la première fonction est appelé
foo ('salut', 10); // la deuxième fonction est appelé
foo (10, 10); // Erreur, la surcharge fonctionne autant avec les deux prototypes.
```

<br>
## Fonctions internes
----------------------
Il est possible de déclarer une fonction dans un bloc. Celle-ci est alors privée à ce bloc.

```D

def foo () {
    {
       def test () {
            println ("Ici");
       }

       test (); // Ok, 'Ici'
     }

     test (); // Erreur, symbole inconnu test
}

def main () {
    test (); // Ok, 'La' (toutes les déclarations se font avant d'entrer dans le bloc)

    def test () { // Ok, cette fonction n'appartient pas au même bloc, elle peut être redéfinie
         println ("La");
    }
}

```

La surcharge fonctionne de la même manière avec les fonctions privées. Elles sont en concurrence avec les fonctions de scope plus large.

```D
def foo () {
}

def main () {
    def foo () {}

    foo (); // Erreur, impossible de déduire quelle fonction appelée.
}

```

<br>
# Importation.
-----------------
Ymir propose un système de module. Chaque fichier correspond à un module importable.
L'importation de module se fait avec la syntaxe.

```D
// Les chemins des fichiers sont relatif à l'emplacement de la compilation.  
import path.to.file, path.to.second.file; 

// importation du fichier $PWD/path/to/file.yr
// et importation du fichier $PWD/path/to/second/file.yr

```

Les import de fichiers  ne sont pas récursif.

 - test2.yr:

 ```D
 def test () {
     println ("Hello World!!");
 }
 ```
 - test.yr:

 ```D
 import test2;
 ```
 - main.yr:

 ```D
 import test;

 def main () {
     test (); // erreur, la fonction test n'existe pas.
 }
 ```

<br>
## Import public
-------------------
les import dis public, sont des import récursif.


 - test2.yr:

 ```D
 def test () {
     println ("Hello World!!");
 }
 ```
 - test.yr:

 ```D
 public import test2;
 ```
 - main.yr:

 ```D
 import test;

 def main () {
     test (); // Ok, 'Hello World!!'
 }
 ```

<br>
# Structure 
-------------
Les Structures permettent de créer de nouveaux types. Leurs instances sont allouées dynamiquement et récupérées par le garbage collector.

Il existe deux syntaxe pour définir les structures:
```D
struct (i : int) A;
struct (f : float, tab : [int]) B;

```

Ou :
```D
struct 
| f : float
| tab : [int]
-> B;
```

Et on les instancie:

```D
let a = A (10), b = B (.1, []);
let b2 = b; // b2 est une reference vers b, aucune recopie n'est faite.

```
L'accès au paramètre se fait avec l'opérateur '_._'

```D
print (a.i);
print (b.f);
print (b.s); // Erreur, la structure B(float) n'a pas d'attribut 's'
b.tab += [10];
```

<br>
## Appel
-----------------

Les attributs des structures sont passés par référence
```D

struct (attr : int) A;

def foo (a : A) {
    a.attr = 123; // les attributs de a sont passé par références
    a = A (2); // a ne sera pas changé en sortie de fonction
}

// ...
let a = A (0);
foo (a);
println (a.attr); // 123
```

<br>
## Structure privée
--------------------

 Il est possible de déclarer des structures dans des blocs, elles deviennent privées à ce bloc.

 ```D
 def test () {}
 def foo () {
     {
        struct (a : int) C;
        struct (a : int, f : float) test; // Erreur, 'test' existe déjà, c'est une fonction
        let a = C (123); // Ok, a est de type 'C'
     }
     let c = C (10); // Erreur, 'C' n'existe pas
 }
 ```


<br>
# Tableau
-----------

Ymir permet l'utilisation de tableau dynamique directement dans le langage sans importation de bibliothèque. 
Les tableaux sont libérés par le garbage collector lorsqu'il n'y a plus de référence sur eux.

<br>
## Declaration
---------------
Les tableaux se créent de la façon suivante :

```D
let a1 = [1, 2, 3]; // array!int
let a2 = [1., 2.]; // array!float
let b = [[1, 2], [3, 4]]; // array!(array!int)
let c = ["salut", 'ca va ?']; // array!string
let d = ["salut", [1, 2]]; // Erreur, type incompatible (string) et (array!int)
```
Ils peuvent être passé en paramètre de fonction, mais uniquement par référence.

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
-----------------

Dans le langage Ymir, il n'existe aucune différence entre un _string_ et un _array!char_. Ces deux types ne sont différenciés que pour permettre une spécification de template lors de l'analyse sémantique.
Ainsi, il est tout à fait possible de passer de l'un à l'autre.


``` D
let a = 'Salut';
println (a); // Ok, 'Salut'
println (cast:array!(char) (a)); // Ok, '[S, a, l, u, t]'
// ou cast:[char] (a);
let b = cast:string (['a', 'b', 'c']);

```

## Operateur

Comme pour les _string_ les tableaux surchargent l'operateur _+_

```D
let a = [1] + [2];
a += [1, 2, 3]; 
println (a); // '[1, 2, 1, 2, 3]'
```


<br>
# Variables
------------------

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
# Type primitif
-------------------
Les types primitifs ont des propriétés qui peuvent être récupérées à partir du type ou d'expression du même type.
```D
// ...
let a = long.max;
let b = ('r').typeid;
```

<br>
### Float et Double
---------------------
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
# Range
---------------------

 Le type range est un type particulier, il prend un type en templates (entre [float, char, int, long]).
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
for (it in a) print (it);
```

<br>
### Types à virgule fixe.
----------------------------

Les types décimaux sont regroupés en deux catégories, signés et non signés.
Un système de promotions est utilisé pour connaître les conversions implicites.
Ymir intérdit la perte de précision implicite, on ne peut affecter (sans cast) que des types de taille inférieur vers supérieur.

```D
let a = 10; // a est de type int.
let b = 1l; // b est de type long.

a = b; // Erreur 
b = a; // Ok

```
Il est aussi impossible de transformer un signé vers un non signé et inversement.

```D
let a = 1u; // a est de type uint
let b = 1; // b est de type int

a = b; // Erreur
b = a; // Erreur

a = cast:uint (b); // Ok

```

Leurs propriétées:

- **init**, la variable d'initialisation d'un int (0)
- **max**, la valeur max d'un int
- **min**, la valeur min d'un int (pas 0)
- **sizeof**, la taille en mémoire d'un int (en octet)
- **typeid**, le type sous forme de chaine

<br>
# Variadics
--------------

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



