function val=closeHPC(j,t1)

submit(j);          % Starten der Jobs
% hier könnte der PC noch parallel eigene Rechnungen durchführen

wait(j);            % Warten bis zur Fertigstellung

val=t1.OutputArguments{1,1};  % Ergebnisse auslesen

delete(j); % Speicher auf dem HPC wieder freigeben (WICHTIG)

end