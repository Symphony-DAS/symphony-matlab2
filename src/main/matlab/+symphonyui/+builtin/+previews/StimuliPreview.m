classdef StimuliPreview < symphonyui.core.ProtocolPreview
    % Displays a cell array of stimuli on a 2D plot. 
    
    properties
        createStimuliFcn
    end
    
    properties (Access = private)
        log
        axes
    end
    
    methods
        
        function obj = StimuliPreview(panel, createStimuliFcn)
            % Constructs a StimuliPreview on the given panel with the given stimuli. createStimuliFcn should be a
            % callback function that creates a cell array of stimuli.
            
            obj@symphonyui.core.ProtocolPreview(panel);
            obj.createStimuliFcn = createStimuliFcn;
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.createUi();
        end
        
        function createUi(obj)
            obj.axes = axes( ...
                'Parent', obj.panel, ...
                'FontName', get(obj.panel, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.panel, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto'); %#ok<CPROP>
            xlabel(obj.axes, 'sec');
            obj.update();
        end
        
        function update(obj)
            cla(obj.axes);
            
            try
                stimuli = obj.createStimuliFcn();
            catch x
                cla(obj.axes);
                text(0.5, 0.5, 'Cannot create stimuli', ...
                    'Parent', obj.axes, ...
                    'FontName', get(obj.panel, 'DefaultUicontrolFontName'), ...
                    'FontSize', get(obj.panel, 'DefaultUicontrolFontSize'), ...
                    'HorizontalAlignment', 'center', ...
                    'Units', 'normalized');
                obj.log.debug(x.message, x);
                return;
            end
            
            if ~iscell(stimuli) && isa(stimuli, 'symphonyui.core.Stimulus')
                stimuli = {stimuli};
            end
            
            ylabels = cell(1, numel(stimuli));
            for i = 1:numel(stimuli)
                [quantities, units] = stimuli{i}.getData();
                x = (1:numel(quantities)) / stimuli{i}.sampleRate.quantityInBaseUnits;
                y = quantities;
                line(x, y, 'Parent', obj.axes);
                ylabels{i} = units;  
            end
            ylabel(obj.axes, strjoin(unique(ylabels), ', '), 'Interpreter', 'none');
        end
        
    end
    
end

