classdef EpochGroup < handle
    
    properties (SetAccess = private)
        id
        label
        startTime
        endTime
        keywords
        attributes
    end
    
    properties (Hidden)
        epochs
        source
        parent
        children
    end
    
    methods (Access = ?symphonyui.core.Experiment)
        
        function obj = EpochGroup(id, label, source, parent)
            obj.id = id;
            obj.parent = parent;
            obj.label = label;
            obj.source = source;
            obj.children = symphonyui.core.EpochGroup.empty(0, 1);
        end
        
        function start(obj)
            obj.startTime = now;
        end
        
        function stop(obj)
            obj.endTime = now;
        end
        
        function addChild(obj, group)
            obj.children(end + 1) = group;
        end
        
    end
    
end

