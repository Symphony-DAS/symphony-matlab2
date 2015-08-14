classdef DaqController < symphonyui.core.CoreObject

    properties
    end

    methods

        function obj = DaqController(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end

        function delete(obj)
            obj.close();
        end

        function beginSetup(obj)
            obj.tryCore(@()obj.cobj.BeginSetup());
        end

        function initialize(obj)

        end

        function close(obj)

        end
        
        function s = getStream(obj, name)
            cstr = obj.tryCoreWithReturn(@()obj.cobj.GetStream(name));
            s = symphonyui.core.DaqStream(cstr);
        end

    end

end