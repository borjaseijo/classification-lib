function [ Yest ] = smoPrediction( rootDir, trainX, trainY, testX , testY )
%SMOPREDICTION Summary of this function goes here
%   Detailed explanation goes here


    % Nombre de los ficheros que almacenan la informacion para clasificar
    % (conjunto de entrenamiento y de test).
    ioTrainFileName = [rootDir filesep 'tmp' filesep 'auxTrain'];
    ioTestFileName = [rootDir filesep 'tmp' filesep 'auxTest'];

    % Se genera un loader para el fichero XRFF
    loaderTrain = weka.core.converters.XRFFLoader();
    ioFileTrain = java.io.File([ioTrainFileName '.xrff']);
    loaderTest = weka.core.converters.XRFFLoader();
    ioFileTest = java.io.File([ioTestFileName '.xrff']);

    datasetToXRFF([trainX trainY], ioTrainFileName);
    datasetToXRFF([testX testY], ioTestFileName);

    loaderTrain.setSource(ioFileTrain);
    dataTrain = loaderTrain.getDataSet();
    loaderTest.setSource(ioFileTest);
    dataTest = loaderTest.getDataSet();

    cl = weka.classifiers.functions.SMO();

    cl.buildClassifier(dataTrain);
    evaluation = weka.classifiers.Evaluation(dataTrain);

    Yest = zeros(dataTest.numInstances(),1);
    for i=0:dataTest.numInstances()-1
        Yest(i+1) = evaluation.evaluateModelOnceAndRecordPrediction(cl, dataTest.instance(i));
    end
    % Se eliminan los ficheros temporales creados.
    delete([ioTrainFileName '.xrff']);
    delete([ioTestFileName '.xrff']);
end

