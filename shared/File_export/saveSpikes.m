function saveSpikes(fileFullPath, SPIKEZ) 
        temp.SPIKEZ=SPIKEZ;
        save(fileFullPath, 'temp', '-v7.3')
end