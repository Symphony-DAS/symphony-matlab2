classdef Entity < symphonyui.core.CoreObject

    properties (SetAccess = private)
        uuid
        keywords
        notes
    end

    properties (Constant)
        DESCRIPTION_TYPE_RESOURCE_NAME = 'descriptionType'
        PROPERTY_DESCRIPTORS_RESOURCE_NAME = 'propertyDescriptors'
    end

    methods

        function obj = Entity(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end

        function i = get.uuid(obj)
            i = char(obj.cobj.UUID.ToString());
        end

        function p = createPreset(obj, name)
            p = symphonyui.core.persistent.EntityPreset(name, obj.getEntityType(), obj.getDescriptionType(), obj.getProperties());
        end

        function applyPreset(obj, preset)
            if ~isempty(preset.entityType) && ~isequal(preset.entityType, obj.getEntityType())
                error('Entity type mismatch');
            end
            if ~isempty(preset.descriptionType) && ~isequal(preset.descriptionType, obj.getDescriptionType())
                error('Description type mismatch');
            end
            obj.setProperties(preset.propertyMap);
        end

        function addProperty(obj, name, value, varargin)
            descriptors = obj.getPropertyDescriptors();
            if ~isempty(descriptors.findByName(name))
                error([name ' already exists']);
            end
            descriptors(end + 1) = symphonyui.core.PropertyDescriptor(name, value, varargin{:});
            obj.tryCore(@()obj.cobj.AddProperty(name, obj.propertyValueFromValue(value)));
            obj.updatePropertyDescriptorsResource(descriptors);
        end

        function setProperties(obj, map)
            exception = [];
            names = map.keys;
            for i = 1:numel(names)
                try
                    obj.setProperty(names{i}, map(names{i}));
                catch x
                    if isempty(exception)
                        exception = MException('symphonyui:core:persistent:Entity', 'Failed to set one or more property values');
                    end
                    exception.addCause(x);
                end
            end
            if ~isempty(exception)
                throw(exception);
            end
        end

        function setProperty(obj, name, value)
            descriptors = obj.getPropertyDescriptors();
            d = descriptors.findByName(name);
            if isempty(d)
                d = symphonyui.core.PropertyDescriptor(name, value, 'isRemovable', true);
                descriptors(end + 1) = d;
            end
            if d.isReadOnly
                error([name ' is read only']);
            end
            d.value = value;
            obj.tryCore(@()obj.cobj.AddProperty(name, obj.propertyValueFromValue(value)));
            obj.updatePropertyDescriptorsResource(descriptors);
        end

        function m = getProperties(obj)
            m = obj.getPropertyDescriptors().toMap();
        end

        function v = getProperty(obj, name)
            descriptors = obj.getPropertyDescriptors();
            d = descriptors.findByName(name);
            if isempty(d)
                error([name ' does not exist']);
            end
            v = d.value;
        end

        function tf = removeProperty(obj, name)
            descriptors = obj.getPropertyDescriptors();
            index = arrayfun(@(d)strcmp(d.name, name), descriptors);
            d = descriptors(index);
            if isempty(d)
                return;
            end
            if ~d.isRemovable
                error([name ' is not removable']);
            end
            descriptors(index) = [];
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveProperty(name));
            obj.updatePropertyDescriptorsResource(descriptors);
        end

        function d = getPropertyDescriptors(obj)
            if any(strcmp(obj.getResourceNames(), obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME))
                d = obj.getResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME);
            else
                d = symphonyui.core.PropertyDescriptor.empty(0, 1);
            end
        end

        function k = get.keywords(obj)
            k = obj.cellArrayFromEnumerable(obj.cobj.Keywords, @char);
        end

        function tf = addKeyword(obj, keyword)
            tf = obj.tryCoreWithReturn(@()obj.cobj.AddKeyword(keyword));
        end

        function tf = removeKeyword(obj, keyword)
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveKeyword(keyword));
        end

        function addResource(obj, name, variable)
            bytes = getByteStreamFromArray(variable);
            obj.tryCoreWithReturn(@()obj.cobj.AddResource('com.mathworks.byte-stream', name, bytes));
        end

        function v = getResource(obj, name)
            cres = obj.tryCoreWithReturn(@()obj.cobj.GetResource(name));
            v = getArrayFromByteStream(uint8(cres.Data));
        end

        function tf = removeResource(obj, name)
            if strcmp(name, obj.DESCRIPTION_TYPE_RESOURCE_NAME)
                error('Cannot remove type resource');
            end
            if strcmp(name, obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME)
                error('Cannot remove property descriptors resource');
            end
            tf = obj.tryCoreWithReturn(@()obj.cobj.RemoveResource(name));
        end

        function n = getResourceNames(obj)
            n = obj.cellArrayFromEnumerable(obj.cobj.GetResourceNames(), @char);
        end

        function n = get.notes(obj)
            n = obj.cellArrayFromEnumerable(obj.cobj.Notes, @symphonyui.core.persistent.Note);
        end

        function n = addNote(obj, text, time)
            if nargin < 3
                time = datetime('now', 'TimeZone', 'local');
            end
            dto = obj.dateTimeOffsetFromDatetime(time);
            cnote = obj.tryCoreWithReturn(@()obj.cobj.AddNote(dto, text));
            n = symphonyui.core.persistent.Note(cnote);
        end
        
        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.ENTITY;
        end

        function t = getDescriptionType(obj)
            if any(strcmp(obj.getResourceNames(), obj.DESCRIPTION_TYPE_RESOURCE_NAME))
                t = obj.getResource(obj.DESCRIPTION_TYPE_RESOURCE_NAME);
            else
                t = [];
            end
        end

    end

    methods (Access = private)

        function updatePropertyDescriptorsResource(obj, descriptors)
            obj.tryCoreWithReturn(@()obj.cobj.RemoveResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME));
            obj.addResource(obj.PROPERTY_DESCRIPTORS_RESOURCE_NAME, descriptors);
        end

    end

    methods (Static)

        function e = newEntity(cobj, description)
            e = symphonyui.core.persistent.Entity(cobj);

            e.addResource(e.DESCRIPTION_TYPE_RESOURCE_NAME, description.getType());

            descriptors = description.getPropertyDescriptors();
            for i = 1:numel(descriptors)
                e.tryCore(@()e.cobj.AddProperty(descriptors(i).name, e.propertyValueFromValue(descriptors(i).value)));
            end
            e.addResource(e.PROPERTY_DESCRIPTORS_RESOURCE_NAME, descriptors);

            names = description.getResourceNames();
            for i = 1:numel(names)
                e.addResource(names{i}, description.getResource(names{i}));
            end
        end

    end

end
