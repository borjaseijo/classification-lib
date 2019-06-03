function [ TestError, MConf, TestError_README ] = ...
    classification_train_test( ShowMessage, MXTrain, MYTrain, MXTest, MYTest, ClassificationMethods, MFeatures )
%CLASSIFICATION_TRAIN_TEST Summary of this function goes here
%   Detailed explanation goes here
%
%   INPUTS:
%   -----------------------------------------------------------------------
%   ShowMessage --------------> Variable que indica si se muestran mensajes
%   de progreso por pantalla o no. Acepta dos valores:
%       - logical(0) o false -> no muestra mensajes por pantalla.
%       - logical(1) o true  -> muestra mensajes por pantalla.
%   MXTrain ------------------> Matriz que representa el dataset de
%   entrenamiento de los distintos clasificadores. La matriz tendrá
%   tantas filas como número de muestras existen en el dataset, y cada
%   columna representará una característica concreta. Por lo tanto, matriz
%   de tamaño [num_muestras x num_caracteristicas].
%   MYTrain ------------------> Matriz que representa las clases en las que
%   se clasifica cada una de las muestras del dataset. La matriz tendrá
%   tantas filas como muestras existen en el dataset, y una única columna
%   que indica la clase a la que está asociada la muestra. Por lo tanto,
%   matriz de tamaño [num_muestras x 1]
%   MXTest -------------------> Matriz que representa el dataset de test de
%   los distintos clasificadores. La matriz tendrá tantas filas como número
%   de muestras existen en el dataset, y cada columna representará una
%   característica concreta. Por lo tanto, matriz de tamaño 
%   [num_muestras x num_caracteristicas].
%   MYTest -------------------> Matriz que representa las clases en las que
%   se clasifica cada una de las muestras del dataset. La matriz tendrá
%   tantas filas como muestras existen en el dataset, y una única columna
%   que indica la clase a la que está asociada la muestra. Por lo tanto,
%   matriz de tamaño [num_muestras x 1]
%   ClassificationMethods ----> Array que contiene los números de los
%   métodos de clasificacion que se utilizan para obtener el porcentaje de
%   error y matrices de confusion de los conjuntos de datos. Los métodos
%   aceptados van de 1 a MAX_CLASSIFICATION_METHODS y se corresponden con
%   los siguientes respectivamente:
%       1 - C4.5
%       2 - Naive Bayes
%       3 - IB1
%       4 - Random Forest
%       5 - SVM (RBF)
%       6 - SMO
%   Por defecto se utilizan todos los metodos de clasificacion para obtener
%   los resultados finales.
%   MFeatures ---------------->
%
%   EJEMPLO DE LLAMADA A LA FUNCION:
%       1 - Cargar un dataset de la carpeta data_test.
%       2 - Dividir el dataset en conjunto de entrenamiento y de test.
%       3 - Realizar una seleccion de caracteristicas mediante la funcion
%           "fs_ensemble_rankings" para obtener la matriz featuresMatrix.
%           Si no se calcula esta matriz se puede omitir el parametro 
%           "MFeatures" y los resultados seran calculados con la totalidad
%           de los conjuntos (Paso opcional).
%       3 - Realizar la llamada a la funcion:
%           [T C] = classification_train_test(true, dataTrain, classesTrain, ...
%                                             dataTest, classesTest, ...
%                                             [1,2,3,4,5,6], featuresMatrix)
%
%   OUTPUTS:
%   -----------------------------------------------------------------------
%   TestError ----------------> Matriz de celdas que representa los
%   porcentajes de error de test finales. La dimension de esta matriz va en
%   concordancia con el tamaño de la matriz de entrada "MFeatures", de
%   manera que el tamaño de esta matriz resultado sea de la forma 
%   [num_metodos_clasificacion x num_metodos_union x num_valores_umbral].
%   Cada elemento celda de la matriz hace referencia a un porcentaje de 
%   error de test obtenido por una configuracion concreta "metodo de 
%   clasificacion - metodo de union - valor de umbral". El orden de los 
%   elementos en las distintas dimensiones siguen el mismo orden que se
%   indico en los parámetros de entrada. Por ejemplo, si se indica 
%   ClassificationMethods = [1,2,3,6] y la matriz "MFeatures" estaba formada
%   previamente por UnionMethods = [1,3,5] y ThresholdValues = [2,6], la 
%   matriz resultado será de la forma:
%   
%   ClassificationMethods [1]
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->    [TError 1,1,2]         [TError 1,1,6]
%       UnionMethod [3] ->    [TError 1,3,2]         [TError 1,3,6]
%       UnionMethod [5] ->    [TError 1,5,2]         [TError 1,5,6]
%
%   ClassificationMethods [2]
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->    [TError 2,1,2]         [TError 2,1,6]
%       UnionMethod [3] ->    [TError 2,3,2]         [TError 2,3,6]
%       UnionMethod [5] ->    [TError 2,5,2]         [TError 2,5,6]
%
%   ClassificationMethods [3]
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->    [TError 3,1,2]         [TError 3,1,6]
%       UnionMethod [3] ->    [TError 3,3,2]         [TError 3,3,6]
%       UnionMethod [5] ->    [TError 3,5,2]         [TError 3,5,6]
%
%   ClassificationMethods [6]
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->    [TError 6,1,2]         [TError 6,1,6]
%       UnionMethod [3] ->    [TError 6,3,2]         [TError 6,3,6]
%       UnionMethod [5] ->    [TError 6,5,2]         [TError 6,5,6]
%
%   MConf --------------------> Matriz de celdas que representa las
%   matrices de confusion finales. La dimension de esta matriz va en
%   concordancia con el tamaño de la matriz de entrada "MFeatures", de
%   manera que el tamaño de esta matriz resultado sea de la forma 
%   [num_metodos_clasificacion x num_metodos_union x num_valores_umbral].
%   Cada elemento celda de la matriz hace referencia a una matriz de
%   confusion obtenida por una configuracion concreta "metodo de 
%   clasificacion - metodo de union - valor de umbral". El orden de los 
%   elementos en las distintas dimensiones siguen el mismo orden que se
%   indico en los parámetros de entrada. Por ejemplo, si se indica 
%   ClassificationMethods = [1,2,3,6] y la matriz "MFeatures" estaba formada
%   previamente por UnionMethods = [1,3,5] y ThresholdValues = [2,6], la 
%   matriz resultado será de la forma:
%   
%   ClassificationMethods [1]
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->    [MConf 1,1,2]          [MConf 1,1,6]
%       UnionMethod [3] ->    [MConf 1,3,2]          [MConf 1,3,6]
%       UnionMethod [5] ->    [MConf 1,5,2]          [MConf 1,5,6]
%
%   ClassificationMethods [2]
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->    [MConf 2,1,2]          [MConf 2,1,6]
%       UnionMethod [3] ->    [MConf 2,3,2]          [MConf 2,3,6]
%       UnionMethod [5] ->    [MConf 2,5,2]          [MConf 2,5,6]
%
%   ClassificationMethods [3]
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->    [MConf 3,1,2]          [MConf 3,1,6]
%       UnionMethod [3] ->    [MConf 3,3,2]          [MConf 3,3,6]
%       UnionMethod [5] ->    [MConf 3,5,2]          [MConf 3,5,6]
%
%   ClassificationMethods [6]
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->    [MConf 6,1,2]          [MConf 6,1,6]
%       UnionMethod [3] ->    [MConf 6,3,2]          [MConf 6,3,6]
%       UnionMethod [5] ->    [MConf 6,5,2]          [MConf 6,5,6]
%

%% MAX STATIC VALUES
MAX_CLASSIFICATION_METHODS = 7;


%% LOAD INITIAL PATH
[wekaPath rootDir] = load_path_cl;


%% DEFAULT VALUES
ClassificationMethodsDefault = [1,2,3,4,5,6];


%% PRE-PROCESS
if (nargin >=5)
    if (~islogical(ShowMessage))
        error('ERROR: El parámetro "ShowMessage" solo acepta los valores "false" (logical(0)) o "true" (logical(1))');
    end
    % nSamplesTrain1: Numero de muestras del conjunto de entrenamiento.
    % nFeatsTrain: Numero de caracteristicas de cada muestra del conjunto de
    % entrenamiento.
    % nSamplesTrain2: Numero de muestras del conjunto de entrenamiento.
    % nClassesTrain: Numero de columnas de clases del conjunto de
    % entrenamiento.
    [nSamplesTrain1, nFeatsTrain] = size(MXTrain);
    [nSamplesTrain2, nClassesTrain] = size(MYTrain);
    if (nSamplesTrain1 ~= nSamplesTrain2)
        error('ERROR: Numero de filas no coincidente entre las matrices de datos de entrada');
    end
    if (nClassesTrain ~= 1)
        error('ERROR: Número de columnas en la matriz de entrada de clases diferente de 1');
    end
    % nSamplesTest1: Numero de muestras del conjunto de test.
    % nFeatsTest: Numero de caracteristicas de cada muestra del conjunto de
    % test.
    % nSamplesTest2: Numero de muestras del conjunto de test.
    % nClassesTest: Numero de columnas de clases del conjunto de test.
    [nSamplesTest1, nFeatsTest] = size(MXTest);
    [nSamplesTest2, nClassesTest] = size(MYTest);
    if (nSamplesTest1 ~= nSamplesTest2)
        error('ERROR: Numero de filas no coincidente entre las matrices de datos de entrada');
    end
    if (nClassesTest ~= 1)
        error('ERROR: Número de columnas en la matriz de entrada de clases diferente de 1');
    end
else error('ERROR: Número de argumentos incorrecto. Al menos debe incluir una matriz de datos y una matriz de clases de entrenamiento y test');
end

switch(nargin)
    case 5,
        if (ShowMessage)
            sprintf('Se utilizan los valores por defecto para "ClassificationMethods"')
            sprintf('Se utilizan todas las características de las matrices de entrenamiento y test para obtener los resultados finales')
        end
        ClassificationMethods = ClassificationMethodsDefault;
        MFeatures = {1:nFeatsTrain};
    case 6,
        if (ShowMessage)
            sprintf('Se utilizan todas las características de las matrices de entrenamiento y test para obtener los resultados finales')
        end
        MFeatures = {1:nFeatsTrain};
    case 7,
    otherwise 
        error('ERROR: Número de argumentos incorrecto.');
end

[nUnionMethods nThresholdValues] = size(MFeatures);
% Se comprueba que los parametros pasados como entrada de la funcion cumplen
% con las caracteristicas especificadas en la documentacion.
if ( min(ClassificationMethods)<1 | max(ClassificationMethods)>MAX_CLASSIFICATION_METHODS )
    error('ERROR: Valor de "ClassificationMethods" incorrecto. Revise cuales son los valores aceptados.');
else nClassificationMethods = length(ClassificationMethods);
end

TestError = zeros(nClassificationMethods, nUnionMethods, nThresholdValues);
MConf = cell(nClassificationMethods, nUnionMethods, nThresholdValues);
TestError_README = cell(nClassificationMethods);


%% PROCESS
% Normalización de los datos
minVector = min(MXTrain);
minVectorTrain = repmat(minVector,size(MXTrain,1),1);
minVectorTest = repmat(minVector,size(MXTest,1),1);
maxVector = max(MXTrain);
maxVectorTrain = repmat(maxVector,size(MXTrain,1),1);
maxVectorTest = repmat(maxVector,size(MXTest,1),1);
MXTrain = (MXTrain-minVectorTrain)./(maxVectorTrain-minVectorTrain);
MXTest = (MXTest-minVectorTest)./(maxVectorTest-minVectorTest);


if (ShowMessage)
    sprintf('Iniciando el proceso de clasificacion...')
end
for c=1:nClassificationMethods
    for u=1:nUnionMethods
        for t=1:nThresholdValues
            % Obtiene el array de las 'nFeats' mejores caracteristicas.
            featsClassif = MFeatures{u,t};
            % Se realiza la clasificacion utilizando los diferentes
            % clasificadores que nos interesan.
            [TestError(c,u,t), MConf{c,u,t}, nomClassifier] = ...
                    classification_method(ClassificationMethods(c), MXTrain(:,featsClassif), ...
                                          MYTrain, MXTest(:,featsClassif), ...
                                          MYTest, rootDir, wekaPath);
            TestError_README{c} = nomClassifier;
            if (ShowMessage)
                sprintf('Resultados [class,union,thres] = [%d,%d,%d] obtenidos correctamente', c, u, t)
            end
        end
    end
    if (ShowMessage)
        sprintf('Resultados del clasificador %d obtenidos correctamente', ClassificationMethods(c))
    end
end