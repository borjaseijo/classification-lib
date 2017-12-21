function datasetToXRFF( dataset, xrffFile )

outputCSV = [xrffFile 'Header.csv'];

% Create and write header
fid = fopen(outputCSV, 'w');
for k=1:(size(dataset,2)-1)
    fprintf(fid,'%s,',['at' int2str(k)]);
end
fprintf(fid, '%s\r\n', 'class');

% Write data
for k=1:size(dataset,1)
    for l=1:size(dataset,2)
        if (l == size(dataset,2))
            fprintf(fid,'%s\r\n',['class' int2str(dataset(k,l))]);
        else
            fprintf(fid,'%g,',dataset(k,l));
        end
    end
end
fclose(fid);

csvloader = weka.core.converters.CSVLoader();
csvloader.setFile(java.io.File(outputCSV));
instances = csvloader.getDataSet();
if (instances.classIndex() == -1)
    instances.setClassIndex(instances.numAttributes()-1);
end

% Save data as XRFF
xrffsaver = weka.core.converters.XRFFSaver();
xrffsaver.setFile(java.io.File([xrffFile '.xrff']));
xrffsaver.setInstances(instances);
xrffsaver.writeBatch();

delete(outputCSV);