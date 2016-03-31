classdef ProtocolPresetsView < appbox.View
    
    events
        ApplyProtocolPreset
        ViewOnlyProtocolPreset
        RecordProtocolPreset
        AddProtocolPreset
        RemoveProtocolPreset
    end
    
    properties (Access = private)
        presetsTable
        applyIcon
        viewOnlyIcon
        recordIcon
        addButton
        removeButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            import symphonyui.app.App;
            
            set(obj.figureHandle, ...
                'Name', 'Protocol Presets', ...
                'Position', screenCenter(360, 200));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Spacing', 1);
            
            obj.presetsTable = uiextras.jTable.Table( ...
                'Parent', mainLayout, ...
                'ColumnName', {'Preset', 'Apply', 'View Only', 'Record'}, ...
                'ColumnFormat', {'', 'button', 'button', 'button'}, ...
                'ColumnFormatData', ...
                    {{}, ...
                    @(h,d)notify(obj, 'ApplyProtocolPreset', symphonyui.ui.UiEventData(d.getSource())), ...
                    @(h,d)notify(obj, 'ViewOnlyProtocolPreset', symphonyui.ui.UiEventData(d.getSource())), ...
                    @(h,d)notify(obj, 'RecordProtocolPreset', symphonyui.ui.UiEventData(d.getSource()))}, ...
                'ColumnMinWidth', [0 40 40 40], ...
                'ColumnMaxWidth', [java.lang.Integer.MAX_VALUE 40 40 40], ...
                'Data', {}, ...
                'UserData', struct('applyEnabled', false, 'viewOnlyEnabled', false, 'recordEnabled', false), ...
                'RowHeight', 40, ...
                'BorderType', 'none', ...
                'ShowVerticalLines', 'off', ...
                'Focusable', 'off', ...
                'Editable', 'off');
            
            obj.applyIcon = App.getResource('icons/apply.png');
            obj.viewOnlyIcon = App.getResource('icons/view_only.png');
            obj.recordIcon = App.getResource('icons/record.png');
            
            % Presets toolbar.
            presetsToolbarLayout = uix.HBox( ...
                'Parent', mainLayout);
            uix.Empty('Parent', presetsToolbarLayout);
            obj.addButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/add.png'), ...
                'Callback', @(h,d)notify(obj, 'AddProtocolPreset'));
            obj.removeButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/remove.png'), ...
                'Callback', @(h,d)notify(obj, 'RemoveProtocolPreset'));
            set(presetsToolbarLayout, 'Widths', [-1 22 22]);
            
            set(mainLayout, 'Heights', [-1 22]);
        end
        
        function show(obj)
            show@appbox.View(obj);
            set(obj.presetsTable, 'ColumnHeaderVisible', false);
        end
        
        function enableApplyProtocolPreset(obj, tf)            
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                data{i, 2} = {obj.applyIcon, tf};
            end
            set(obj.presetsTable, 'Data', data);
            
            enables = get(obj.presetsTable, 'UserData');
            enables.applyEnabled = tf;
            set(obj.presetsTable, 'UserData', enables);
        end
        
        function enableViewOnlyProtocolPreset(obj, tf)
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                data{i, 3} = {obj.viewOnlyIcon, tf};
            end
            set(obj.presetsTable, 'Data', data);
            
            enables = get(obj.presetsTable, 'UserData');
            enables.viewOnlyEnabled = tf;
            set(obj.presetsTable, 'UserData', enables);
        end
        
        function enableRecordProtocolPreset(obj, tf)
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                data{i, 4} = {obj.recordIcon, tf};
            end
            set(obj.presetsTable, 'Data', data);
            
            enables = get(obj.presetsTable, 'UserData');
            enables.recordEnabled = tf;
            set(obj.presetsTable, 'UserData', enables);
        end
        
        function setProtocolPresets(obj, data)
            enables = get(obj.presetsTable, 'UserData');
            d = cell(size(data, 1), 4);
            for i = 1:size(d, 1)
                d{i, 1} = toDisplayName(data{i, 1}, data{i, 2});
                d{i, 2} = {obj.applyIcon, enables.applyEnabled};
                d{i, 3} = {obj.viewOnlyIcon, enables.viewOnlyEnabled};
                d{i, 4} = {obj.recordIcon, enables.recordEnabled};
            end
            set(obj.presetsTable, 'Data', d);
        end
        
        function d = getProtocolPresets(obj)
            presets = obj.presetsTable.getColumnData(1);
            d = cell(numel(presets), 2);
            for i = 1:size(d, 1)
                [name, protocolId] = fromDisplayName(presets{i});
                d{i, 1} = name;
                d{i, 2} = protocolId;
            end
        end
        
        function addProtocolPreset(obj, name, protocolId)
            enables = get(obj.presetsTable, 'UserData');
            obj.presetsTable.addRow({toDisplayName(name, protocolId), ...
                {obj.applyIcon, enables.applyEnabled}, ...
                {obj.viewOnlyIcon, enables.viewOnlyEnabled}, ...
                {obj.recordIcon, enables.recordEnabled}});
        end
        
        function removeProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(fromDisplayName(c), name), presets));
            obj.presetsTable.removeRow(index); %#ok<FNDSB>
        end
        
        function n = getSelectedProtocolPreset(obj)
            rows = get(obj.presetsTable, 'SelectedRows');
            if isempty(rows)
                n = [];
            else
                n = fromDisplayName(obj.presetsTable.getValueAt(rows(1), 1));
            end
        end
        
        function setSelectedProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(fromDisplayName(c), name), presets));
            set(obj.presetsTable, 'SelectedRows', index);
        end
        
    end
    
end

function html = toDisplayName(name, protocolId)
    html = ['<html>' name '<br><font color="gray">' protocolId '</font></html>'];
end

function [name, protocolId] = fromDisplayName(html)
    split = strsplit(html, {'<', '>'});
    name = split{3};
    protocolId = split{6};
end
