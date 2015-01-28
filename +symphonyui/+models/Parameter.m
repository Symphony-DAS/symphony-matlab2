classdef Parameter < handle
    
    properties
        name
        type
        value
        units
        category
        displayName
        description
        readOnly = false
        dependent = false
    end
    
    methods
        
        function obj = Parameter(name, value)
            obj.name = name;
            obj.value = value;
        end
        
    end
    
end
