function saveSpikes(fileFullPath, SPIKEZ) % filename, SPIKEZ (=Structure)
        temp.SPIKEZ=SPIKEZ;
        save(fileFullPath, 'temp')
end