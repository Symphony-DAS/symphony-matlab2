classdef RigRepository < symphonyui.infra.DiscoverableRepository & symphonyui.util.mixin.Observer
    
    properties (Access = private)
        config
    end
    
    methods
        
        function obj = RigRepository(config)
            obj = obj@symphonyui.infra.DiscoverableRepository('symphonyui.core.Rig');
            obj.config = config;
            obj.addListener(config, 'Changed', @obj.onChangedConfig);
            obj.init();
        end
        
    end
    
    methods (Access = private)
        
        function onChangedConfig(obj, ~, data)
            if ~strcmp(data.key, symphonyui.infra.Settings.GENERAL_RIG_SEARCH_PATH)
                return;
            end
            obj.init();
        end
        
        function init(obj)
            obj.setSearchPaths(obj.config.get(symphonyui.infra.Settings.GENERAL_RIG_SEARCH_PATH));
            obj.loadAll();
        end
        
    end
    
end

