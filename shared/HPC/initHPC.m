function j=initHPC()
% clientTaskCompleted.m f�r Callbacks in den Pfad aufnehmen

c = parcluster('BioMEMS');                  % Verbindung erstellen
j = createJob(c);                           % Einen Job erstellen 


end