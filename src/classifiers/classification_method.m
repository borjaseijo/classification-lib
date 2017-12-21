function [ testError, confM, nomClassifier ] = ...
    classification_method(which, trainX, trainY, testX, testY, rootDir, wekapath)
% Inputs:
% which - Number to select one of the following kinds of classifiers.
%
% 1 - C4.5
% 2 - Naive Bayes
% 3 - IB1
% 4 - Random Forest
% 5 - SVM (RBF)
% 6 - SMO
%
% input - Input dataset
%
% Outputs:
% 
    % Nombre de los ficheros que almacenan la informacion para clasificar
    % (conjunto de entrenamiento y de test).
    dataTrainFileName = [rootDir filesep 'tmp' filesep 'auxTrain.arff'];
    dataTestTempFileName = [rootDir filesep 'tmp' filesep 'auxTest2.arff'];
    dataTestFileName = [rootDir filesep 'tmp' filesep 'auxTest.arff'];
        
    % Se generan los ficheros .arff que contienen la informacion de los
    % conjuntos de entrenamiento y de test.
    mat2arff(rootDir, dataTrainFileName, [trainX trainY], wekapath);
    mat2arff(rootDir, dataTestTempFileName, [testX testY], wekapath);
    
    s = 'Weka exception';
    if (isnumeric(which))
        while (~isempty(findstr(s, 'Weka exception')))
            % Se igualan las cabeceras de los ficheros (se copia la cabecera del
            % fichero de entrenamiento al fichero de test)
            filechange = change_header_test(dataTrainFileName, dataTestTempFileName, dataTestFileName);
            switch(which)
                case 1, % C4.5
                    nomClassifier = 'C4.5';
                    s = evalc(['!java ', wekapath, ' -Xmx4g weka.classifiers.trees.J48 -i -C 0.50 -M 2 -t "', dataTrainFileName, '" -T "', dataTestFileName, '" -d j48.model']);
                case 2, % Naive Bayes
                    nomClassifier = 'Naive Bayes';
                    s = evalc(['!java ', wekapath, ' -Xmx4g weka.classifiers.bayes.NaiveBayes -i -t "', dataTrainFileName, '" -T "', dataTestFileName, '" -d nb.model']);
                case 3, % IB1
                    nomClassifier = 'IB1';
                    s = evalc(['!java ', wekapath, ' -Xmx4g weka.classifiers.lazy.IB1 -i -t "', dataTrainFileName, '" -T "', dataTestFileName, '" -d ib1.model']);
                case 4, % Random Forest
                    nomClassifier = 'Random Forest';
                    s = evalc(['!java ', wekapath, ' -Xmx4g weka.classifiers.trees.RandomForest -i -t "', dataTrainFileName, '" -T "', dataTestFileName, '" -d rf.model']);
                case 5, % SVM (RBF)
                    nomClassifier = 'SVM(RBF)';
                    param = struct('ker', 2, 'C', 1, 'gamma', 0.01);
                    % Se realiza la clasificacion del suconjunto de test mediante el
                    % modelo entrenado.
                    [acc, Yest] = svmPrediction(trainX, trainY, testX, testY, param);
                    % Se calcula el error cometido en la clasificación.
                    testError = (1 - acc/100)*100;
                    % Se genera la matriz de confusion.
                    confM = cfmatrix(testY, Yest, unique(testY), 0);
                    s = 'sucess';
                case 6, % SMO
                    nomClassifier = 'SMO';
                    Yest = smoPrediction(rootDir, trainX, trainY, testX, testY);
                    % Se calcula el error cometido en la clasificación.
                    testError = calculateError(Yest, testY)*100;
                    % Se genera la matriz de confusion.
                    confM = cfmatrix(testY, Yest, unique(testY), 0);
                    s = 'sucess';
                case 7, % Adaboost
                    nomClassifier = 'Adaboost';
                    s = evalc(['!java ', wekapath, ' -Xmx4g weka.classifiers.meta.AdaBoostM1 -t "', dataTrainFileName, '" -T "', dataTestFileName]);
                otherwise
                    nomClassifier = 'none';
                    s = 'error';
            end
        end
    else
        error('classifier:incorrectClassifier', 'Incorrect classifier');
    end;

    if (isnumeric(which))
        if ( (which >= 1 && which <= 4) || (which == 7) )
            % Training results
%             t1=findstr('=== Error on training data ===',s);
%             s2=s([t1+30:length(s)]);
%             t2=findstr('Correctly Classified Instances',s2);
%             t=findstr('%',s2);
%             resultChar = s2([t(1)-9:t(1)-1]);
% 
%             resultTrain = str2double(resultChar);
%             clear t2 t resultChar

%             t2=findstr('ROC Area  Class',s2);
%             s3 = s2([t2:length(s2)]);
%             auxMeasuresTrain(1,1) = str2double(s3(33:38));
%             auxMeasuresTrain(1,2) = str2double(s3(118:123));
%             auxMeasuresTrain(1,3) = str2double(s3(203:208));
%             auxMeasuresTrain(1,4) = str2double(s3(288:293));
% 
%             t3=findstr('Weighted Avg.',s3);
%             s4 = s3([t3:length(s3)]);
%             rocTrain = str2double(s4(69:74));
% 
%             clear t1 s2 t2 t resultChar

            % Test results
            t1=findstr('=== Error on test data ===',s);
            s2=s([t1+26:length(s)]);
            t2=findstr('Incorrectly Classified Instances',s2);
            s2=s2([t2+32:length(s2)]);
            t=findstr('%',s2);
            resultChar = s2([t(1)-9:t(1)-1]);

            testError = str2double(resultChar);

            clear t2 t resultChar

            % Confusion Matrix results
            t2=findstr('=== Confusion Matrix ===',s2);
            s3 = s2([t2+24:length(s2)]);
            t3=findstr('classified as',s3);
            s3 = s3([t3+13:length(s3)]);
            i = 1;
            while(length(s3) > 0)
                [rowtoken s3] = strtok(s3, '|');
                [classtoken s3] = strtok(s3, char(10));
                if (~isempty(str2num(rowtoken)))
                    confM(i,:) = str2num(rowtoken);
                    i = i + 1;
                end
            end
            clear t1 s2 t2 t
        end
    end
    %delete(dataTrainFileName);
    %delete(dataTestTempFileName);
    %delete(dataTestFileName);    
end