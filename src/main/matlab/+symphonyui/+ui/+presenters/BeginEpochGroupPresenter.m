classdef BeginEpochGroupPresenter < appbox.Presenter

    properties (Access = private)
        log
        settings
        documentationService
        initialParent
        initialSource
    end

    methods

        function obj = BeginEpochGroupPresenter(documentationService, initialParent, initialSource, view)
            if nargin < 2
                initialParent = [];
            end
            if nargin < 3 || isempty(initialSource)
                sources = documentationService.getExperiment().allSources();
                if isempty(sources)
                    initialSource = [];
                else
                    initialSource = sources{end};
                end
            end
            if nargin < 4
                view = symphonyui.ui.views.BeginEpochGroupView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.BeginEpochGroupSettings();
            obj.documentationService = documentationService;
            obj.initialParent = initialParent;
            obj.initialSource = initialSource;
        end

    end

    methods (Access = protected)

        function willGo(obj, ~, ~)
            obj.populateParentList();
            obj.populateSourceList();
            obj.populateDescriptionList();
            obj.selectParent(obj.initialParent);
            obj.selectSource(obj.initialSource);
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Begin', @obj.onViewSelectedBegin);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function populateParentList(obj)
            currentGroup = obj.documentationService.getCurrentEpochGroup();
            if isempty(currentGroup)
                parents = {};
            else
                parents = flip([{currentGroup} currentGroup.getAncestors()]);
            end

            names = cell(1, numel(parents));
            for i = 1:numel(parents)
                names{i} = parents{i}.label;
            end
            names = [{'(None)'}, names];
            values = [{[]}, parents];

            obj.view.setParentList(names, values);
            obj.view.enableSelectParent(numel(parents) > 0);
        end

        function selectParent(obj, parent)
            obj.view.setSelectedParent(parent);
            obj.populateDescriptionList();
            obj.updateStateOfControls();
        end

        function populateSourceList(obj)
            sources = obj.documentationService.getExperiment().allSources();

            names = cell(1, numel(sources));
            for i = 1:numel(sources)
                names{i} = sources{i}.label;
            end

            if numel(sources) > 0
                obj.view.setSourceList(names, sources);
            else
                obj.view.setSourceList({'(None)'}, {[]});
            end
            obj.view.enableSelectSource(numel(sources) > 0);
        end

        function selectSource(obj, source)
            obj.view.setSelectedSource(source);
        end

        function populateDescriptionList(obj)
            parent = obj.documentationService.getCurrentEpochGroup();
            if isempty(parent)
                parentType = [];
            else
                parentType = parent.getDescriptionType();
            end
            classNames = obj.documentationService.getAvailableEpochGroupDescriptions(parentType);

            displayNames = cell(1, numel(classNames));
            for i = 1:numel(classNames)
                split = strsplit(classNames{i}, '.');
                displayNames{i} = appbox.humanize(split{end});
            end

            if numel(classNames) > 0
                obj.view.setDescriptionList(displayNames, classNames);
            else
                obj.view.setDescriptionList({'(None)'}, {[]});
            end
            obj.view.enableSelectDescription(numel(classNames) > 0);
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    if obj.view.getEnableBegin()
                        obj.onViewSelectedBegin();
                    end
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedBegin(obj, ~, ~)
            obj.view.update();

            parent = obj.view.getSelectedParent();
            source = obj.view.getSelectedSource();
            description = obj.view.getSelectedDescription();
            try
                while obj.documentationService.getCurrentEpochGroup() ~= parent
                    obj.documentationService.endEpochGroup();
                end
                group = obj.documentationService.beginEpochGroup(source, description);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end

            obj.result = group;
            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

        function updateStateOfControls(obj)
            sourceList = obj.view.getSourceList();
            hasSource = ~isempty(sourceList{1});
            descriptionList = obj.view.getDescriptionList();
            hasDescription = ~isempty(descriptionList{1});

            obj.view.enableBegin(hasSource && hasDescription);
        end

    end

end
