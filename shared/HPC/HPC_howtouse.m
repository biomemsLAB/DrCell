% clientTaskCompleted.m für Callbacks in den Pfad aufnehmen

c = parcluster('BioMEMS');                  % Verbindung erstellen
j = createJob(c);                           % Einen Job erstellen 
t1 = createTask(j, @randi, 1, {3,3,3});   % Aufgaben des Jobs definieren
% (Jobname, @Funktion, Anzahl der Rückgebevariablen,{Übergabeparameter});


submit(j);          % Starten der Jobs
% hier könnte der PC noch parallel eigene Rechnungen durchführen

wait(j);            % Warten bis zur Fertigstellung

%val=t1.OutputArguments{1,1};  % Ergebnisse auslesen
t1.OutputArguments{1,1}

% val= randi(3,3,3);



delete(j); % Speicher auf dem HPC wieder freigeben (WICHTIG)

