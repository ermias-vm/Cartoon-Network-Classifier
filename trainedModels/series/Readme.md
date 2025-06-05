# 🎨 Modelo Entrenado para Clasificación de Series de Cartoon Network

## 📋 Descripción del Modelo

Este directorio contiene un modelo de clasificación entrenado para reconocer automáticamente diferentes series de dibujos animados de Cartoon Network. El modelo ha sido desarrollado utilizando técnicas de aprendizaje automático supervisado.

## 📊 Especificaciones del Dataset

### Composición del Dataset
- **Total de imágenes**: 5,000 imágenes
- **Imágenes para entrenamiento**: 3,500 (70% del dataset total)
- **Imágenes para prueba**: 1,500 (30% del dataset total)
- **Número de series**: 10 series diferentes
- **Distribución por serie**: 350 imágenes de entrenamiento por cada serie

### 📺 Series Incluidas
El modelo está entrenado para clasificar las siguientes series:
1. Barrufets (Los Pitufos)
2. Bob Esponja
3. Gat i Gos (Catdog)
4. Gumball
5. Hora de Aventuras (Adventure Time)
6. Oliver y Benji
7. Padre de Familia (Family Guy)
8. Pokémon
9. South Park
10. Tom y Jerry

## 🤖 Algoritmo de Clasificación

### Método Utilizado
- **Algoritmo**: Support Vector Machine (SVM)
- **Tipo de kernel**: Cuadrático 

### 🔧 Características del SVM Cuadrático
El kernel cuadrático permite al modelo:
- 📈 Capturar relaciones no lineales en los datos de imagen
- 🎯 Crear límites de decisión más complejos entre las clases
- ✨ Obtener mejor separación entre series con características visuales similares

## 📈 Rendimiento del Modelo

### 🎯 Métricas de Precisión
- **Precisión General**: 97.7% 
- **Dataset de Evaluación**: Conjunto de prueba (30% de los datos)
