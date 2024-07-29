## Índice (File Tree Generation)
- [Árbol de directorios](#Directory-Tree)
- [Contenido de los archivos](#Files-Contents)

### Directory Tree:
```tree
tree_tests
│   1.txt
│   
└───1
    │   2.txt
    │   
    ├───a
    │       a.txt
    │       
    ├───b
    │       b.md
    │       
    └───d
            d.js
            
```


### Files Contents:
#### Archivo `1.txt`: 
````txt 
File in the main path
````

#### Archivo `1\2.txt`: 
````txt 
File in the secondary path
````

#### Archivo `1\a\a.txt`: 
````txt 
Line 1
Line 2
Text Text
````

#### Archivo `1\b\b.md`: 
````md 
##### Line 1
##### Line 2

```
MarkDown code
```
````

#### Archivo `1\d\d.js`: 
````js 
console.log("Line 1");
console.log("Line 2");
// JavaScript comment
````