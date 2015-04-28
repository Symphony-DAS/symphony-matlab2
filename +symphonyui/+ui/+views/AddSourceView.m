classdef AddSourceView < symphonyui.ui.View

    events
        Add
        Cancel
    end

    properties (Access = private)
        parentDropDown
        labelField
        addButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, 'Name', 'Add Source');
            set(obj.figureHandle, 'Position', screenCenter(300, 111));
            set(obj.figureHandle, 'WindowStyle', 'modal');

            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            sourceLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            sourceLabelSize = 40;
            obj.parentDropDown = createLabeledDropDownMenu(sourceLayout, 'Parent:', sourceLabelSize);
            obj.labelField = createLabeledTextField(sourceLayout, 'Label:', sourceLabelSize);
            
            set(sourceLayout, 'Sizes', [25 25]);

            % Add/Cancel controls.
            controlsLayout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiextras.Empty('Parent', controlsLayout);
            obj.addButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Add', ...
                'Callback', @(h,d)notify(obj, 'Add'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Sizes', [-1 75 75]);

            set(mainLayout, 'Sizes', [-1 25]);

            % Set add button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.addButton);
            end
        end
        
        function enableSelectParent(obj, tf)
            set(obj.parentDropDown, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function p = getSelectedParent(obj)
            p = symphonyui.ui.util.getSelectedValue(obj.parentDropDown);
        end

        function setSelectedParent(obj, p)
            symphonyui.ui.util.setSelectedValue(obj.parentDropDown, p);
        end

        function l = getParentList(obj)
            l = get(obj.parentDropDown, 'String');
        end

        function setParentList(obj, l)
            symphonyui.ui.util.setStringList(obj.parentDropDown, l);
        end
        
        function l = getLabel(obj)
            l = get(obj.labelField, 'String');
        end
        
        function requestLabelFocus(obj)
            obj.requestFocus(obj.labelField);
        end

    end

end
