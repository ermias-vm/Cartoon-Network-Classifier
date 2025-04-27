# Práctica Final de VC-FIB

Este proyecto corresponde a la práctica final de la asignatura **Visión por Computador** de la **FIB (Facultad de Informática de Barcelona)**.

El objetivo es desarrollar un sistema capaz de **clasificar automáticamente fotogramas** de series de animación para identificar:
- 📺 A qué **serie** pertenece la imagen.
- 👤 Qué **personaje** (o personajes) aparecen en ella.

---

## 🚀 Instrucciones de uso

---
### 1. 📂 Configura la ruta de trabajo en MATLAB

Antes de ejecutar cualquier script, sitúa la ruta de trabajo de MATLAB en la carpeta raíz del proyecto:

```matlab
C:\....\Cartoon-Network-Classifier
```

---

### 2. ▶️ Ejecuta el script principal

Ejecuta el menú principal en la consola de MATLAB con:

```matlab
classifier
```

También, puedes hacer click derecho en `classifier.m` y pulsar la opción de Run (F9).

---

### 3. 📝 Opciones del menú principal

Al ejecutar `classifier.m`, verás un menú con las siguientes opciones:

1. **Identificar una SERIE dada una imagen**  
   - Selecciona una imagen (aleatoria o manualmente) y el modelo predecirá a qué serie pertenece.

2. **Identificar un PERSONAJE dada una imagen**  
   - Selecciona una imagen (aleatoria o manualmente) y el modelo predecirá qué personaje aparece.  
   - _Nota: Solo disponible si tienes entrenado el modelo de personajes y las características correspondientes._

3. **Test Detección de Series**  
   - Selecciona una carpeta de una serie y realiza un test automático sobre todas las imágenes de esa serie, mostrando el porcentaje de aciertos.

4. **Test Detección de Personajes**  
   - Selecciona una carpeta de un personaje y realiza un test automático sobre todas las imágenes de ese personaje, mostrando el porcentaje de aciertos.

5. **Salir**  
   - Finaliza el script.

### ⚠️ Importante

- **La carpeta `out` debe contener los siguientes archivos generados automáticamente para el correcto funcionamiento del sistema:**

    ```
    out/
    ├─ tablaImagenesSeries.mat
    ├─ tablaImagenesSeriesTest.mat
    ├─ caracteristicasSeries.mat
    ├─ caracteristicas_norm_S.mat
    ├─ minXseries.mat
    ├─ maxXseries.mat
    ├─ caracteristicasPersonajes.mat
    ├─ caracteristicas_norm_P.mat
    ├─ minXpersonajes.mat
    └─ maxXpersonajes.mat
    ```

> ⚠️ **Nota:**  
> Si la carpeta `out` está vacía o se ha eliminado, ejecuta la opción de generación de tablas y características desde el menú principal para regenerar estos archivos.

- **No modifiques la estructura de carpetas ni los nombres de los archivos sin actualizar las rutas en los scripts.**

### 💡 Ejemplo de flujo típico

1. Coloca tus imágenes en las carpetas correspondientes dentro de `datasetSeries`.
2. Ejecuta el script `classifier` en MATLAB.
3. Selecciona la opción deseada del menú para identificar series o hacer tests.

---
