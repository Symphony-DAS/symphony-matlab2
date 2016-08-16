classdef NiSimulationDaqController < symphonyui.builtin.daqs.SimulationDaqController
    % Manages a simulated National Instruments DAQ interface (requires no attached hardware).
    
    methods
        
        function obj = NiSimulationDaqController()
            for i = 1:32
                name = ['ai' num2str(i-1)];
                cstr = Symphony.Core.DAQInputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = 'V';
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end
            
            for i = 1:4
                name = ['ao' num2str(i-1)];
                cstr = Symphony.Core.DAQOutputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = 'V';
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            for i = 1:3
                name = ['port' num2str(i-1)];
                cstr = Symphony.Core.DAQInputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = Symphony.Core.Measurement.UNITLESS;
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end

            for i = 1:3
                name = ['port' num2str(i-1)];
                cstr = Symphony.Core.DAQOutputStream(name, obj.cobj);
                cstr.MeasurementConversionTarget = Symphony.Core.Measurement.UNITLESS;
                cstr.Clock = obj.cobj.Clock;
                obj.addStream(symphonyui.core.DaqStream(cstr));
            end
            
            Symphony.Core.Converters.Register(Symphony.Core.Measurement.UNITLESS, Symphony.Core.Measurement.UNITLESS, Symphony.Core.ConvertProcs.Scale(1, Symphony.Core.Measurement.UNITLESS));
            Symphony.Core.Converters.Register('V', 'V', Symphony.Core.ConvertProcs.Scale(1, 'V'));
            Symphony.Core.Converters.Register(Symphony.Core.Measurement.NORMALIZED, 'V', Symphony.Core.ConvertProcs.Scale(10, 'V'));
            Symphony.Core.Converters.Register('V', Symphony.Core.Measurement.NORMALIZED, Symphony.Core.ConvertProcs.Scale(1/10, Symphony.Core.Measurement.NORMALIZED));
            
            obj.sampleRate = symphonyui.core.Measurement(10000, 'Hz');
            obj.sampleRateType = symphonyui.core.PropertyType('denserealdouble', 'scalar', {1000, 10000, 20000, 50000});

            %obj.simulationRunner = @(output, timeStep)obj.loopbackRunner(output, timeStep);
        end
        
    end
    
    methods (Access = private)
        
    end
    
end

