classdef AddKeywordView < symphonyui.ui.View
    
    events
        Add
        Cancel
    end
    
    properties (Access = private)
        textField
        addButton
        cancelButton
    end
    
    methods
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            set(obj.figureHandle, 'Name', 'Add Keyword');
            set(obj.figureHandle, 'Position', screenCenter(300, 79));
            set(obj.figureHandle, 'WindowStyle', 'modal');
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            keywordLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.textField = uicontrol( ...
                'Parent', keywordLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            
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
            
            set(mainLayout, 'Sizes', [25 25]);
            
            % Set add button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.addButton);
            end
        end
        
        function t = getText(obj)
            t = get(obj.textField, 'String');
        end
        
        function setTextCompletionList(obj, l)
            j = findjobj(obj.textField);
            org.jdesktop.swingx.autocomplete.AutoCompleteDecorator.decorate(j, java.util.Arrays.asList(l), false);
        end
        
        function requestTextFocus(obj)
            obj.requestFocus(obj.textField);
        end
        
    end
    
end

