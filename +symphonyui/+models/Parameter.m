classdef Parameter < hgsetget
    
    properties
        name
        value
        type
        units
        category
        displayName
        description
        isReadOnly = false
        isDependent = false
        isValid = true
    end
    
    methods
        
        function obj = Parameter(name, value, varargin)
            obj.name = name;
            obj.value = value;
            
            if nargin > 2
                obj.set(varargin{:});
            end
        end
        
        function v = get.value(obj)
            if isempty(obj.value) && ~isempty(obj.type) && ~isempty(obj.type.domain)
                domain = obj.type.domain;
                if iscell(domain)
                    v = domain{1};
                else
                    v = domain(1);
                end
                return;                
            end
            
            v = obj.value;
        end
        
    end
    
end

