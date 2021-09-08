% test if there is enough memory available

function flag_enoughMemory = testMemory()
if ~isunix % memory function is not available for linux
    [~,systemview] = memory;
    flag_enoughMemory = systemview.PhysicalMemory.Total>=((3/4)*systemview.PhysicalMemory.Available);
else
    flag_enoughMemory = 1; % if linux, assume enough memory is available
end
end