classdef ExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        experiment
    end
    
    properties (Constant, Access = private)
        EXPERIMENT_ID_PREFIX = 'X';
        SOURCE_ID_PREFIX = 'S';
        EPOCH_GROUP_ID_PREFIX = 'G';
        EPOCH_ID_PREFIX = 'E';
    end
    
    methods

        function obj = ExperimentPresenter(experiment, app, view)
            if nargin < 3
                view = symphonyui.ui.views.ExperimentView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.experiment = experiment;
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateExperimentTree();
            obj.selectExperiment(obj.experiment);
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            
            e = obj.experiment;
            obj.addListener(e, 'AddedSource', @obj.onExperimentAddedSource);
            obj.addListener(e, 'BeganEpochGroup', @obj.onExperimentBeganEpochGroup);
            obj.addListener(e, 'EndedEpochGroup', @obj.onExperimentEndedEpochGroup);
        end

    end

    methods (Access = private)
        
        function populateExperimentTree(obj)
            obj.view.setExperimentNode(obj.experiment.name, obj.getNodeId(obj.experiment));
            
            sources = obj.experiment.sources;
            for i = 1:numel(sources)
                obj.addSource(source(i));
            end
            
            groups = obj.experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups(i));
            end
        end
        
        function selectExperiment(obj, experiment)
            obj.view.setSelectedNode(obj.getNodeId(experiment));
            obj.populateProperties(experiment);
        end
        
        function onExperimentAddedSource(obj, ~, data)
            source = data.source;
            obj.addSource(source);
            obj.selectSource(source);
        end
        
        function addSource(obj, source)
            if isempty(source.parent)
                parent = obj.experiment;
            else
                parent = source.parent;
            end
            
            obj.view.addSourceNode(obj.getNodeId(parent), source.label, obj.getNodeId(source));
            
            sources = source.children;
            for i = 1:numel(sources)
                obj.addSource(sources(i));
            end
        end
        
        function selectSource(obj, source)
            obj.view.setSelectedNode(obj.getNodeId(source));
            obj.populateProperties(source);
        end
        
        function populateProperties(obj, entity)
            try
                properties = uiextras.jide.PropertyGridField.GenerateFrom(entity);
            catch x
                properties = uiextras.jide.PropertyGridField.empty(0, 1);
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
            end
            obj.view.setProperties(properties);
        end
        
        function onExperimentBeganEpochGroup(obj, ~, data)
            group = data.epochGroup;
            obj.addEpochGroup(group);
            obj.selectEpochGroup(group);
            obj.view.setEpochGroupNodeCurrent(obj.getNodeId(group));
        end
        
        function addEpochGroup(obj, group)
            if isempty(group.parent)
                parent = obj.experiment;
            else
                parent = group.parent;
            end
            
            obj.view.addEpochGroupNode(obj.getNodeId(parent), group.label, obj.getNodeId(group));
            
            groups = group.children;
            for i = 1:numel(groups)
                obj.addEpochGroup(groups(i));
            end
        end
        
        function selectEpochGroup(obj, group)
            obj.view.setSelectedNode(obj.getNodeId(group));
            obj.populateProperties(group);
        end
        
        function onExperimentEndedEpochGroup(obj, ~, data)
            group = data.epochGroup;
            obj.view.collapseNode(obj.getNodeId(group));
            obj.view.setEpochGroupNodeNormal(obj.getNodeId(group));
        end
        
        function addEpoch(obj, epoch)
            obj.view.addEpochNode(obj.getNodeId(epoch.epochGroup), epoch.label, obj.getNodeId(epoch));
        end
        
        function selectEpoch(obj, epoch)
            obj.view.setSelectedNode(obj.getNodeId(epoch));
            obj.populateProperties(epoch);
        end
        
        function onViewSelectedNode(obj, ~, ~)
            nodeId = obj.view.getSelectedNode();
            prefix = nodeId(1);
            id = nodeId(2:end);
            switch prefix
                case obj.EXPERIMENT_ID_PREFIX
                    obj.selectExperiment(obj.experiment);
                case obj.SOURCE_ID_PREFIX
                    source = obj.experiment.getSource(id);
                    obj.selectSource(source);
                case obj.EPOCH_GROUP_ID_PREFIX
                    group = obj.experiment.getEpochGroup(id);
                    obj.selectEpochGroup(group);
                case obj.EPOCH_ID_PREFIX
                    epoch = obj.experiment.getEpoch(id);
                    obj.selectEpoch(epoch);
            end
        end
        
        function i = getNodeId(obj, entity)
            switch class(entity)
                case 'symphonyui.core.Experiment'
                    prefix = obj.EXPERIMENT_ID_PREFIX;
                case 'symphonyui.core.Source'
                    prefix = obj.SOURCE_ID_PREFIX;
                case 'symphonyui.core.EpochGroup'
                    prefix = obj.EPOCH_GROUP_ID_PREFIX;
                case 'symphonyui.core.Epoch'
                    prefix = obj.EPOCH_ID_PREFIX;
            end
            i = [prefix, entity.id];
        end

    end

end
