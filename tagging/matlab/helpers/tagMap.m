% tagMap
% Object encapsulating the tags and value labels of one type
%
% Usage:
%   >>  tMap = tagMap()
%   >>  tMap = tagMap('key1', 'value1', ...)
%
% Description:
% tMap = tagMap() creates an object that holds the associations of
% tags and values for one type or group name. By default the name
% of the field or type is 'type'.
%
% tMap = tagMap('key1', 'value1') where the key-value pair is:
%
%        'Field'                Name of field for this group of tags
%
% Notes:
%
%
% Description of update options for addValue:
%    'merge'         If the structure code is not a key of this map, add
%                    the entire structure as is. Otherwise, if the
%                    structure code is a key for this map, then merge the
%                    tags with those of the existing structure, using the
%                    PreservePrefix value to determine how to combine the
%                    tags.
%    'replace'       If the structure code is not a key of this map,
%                    do nothing. Otherwise, if the structure code is a
%                    key for this map, then completely replace the map
%                    value structure with this structure.
%    'update'        If the structure code is not a key of this map,
%                    do nothing. Otherwise, if the structure code is a
%                    key for this map, then merge the tags with those
%                    of the existing structure, using the PreservePrefix
%                    value to determine how to combine the tags.
%    'none'          Don't do any updating
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for tagMap:
%
%    doc tagMap
%
% See also: findtags, tageeg, tagdir, tagstudy, dataTags
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%
% $Log: tagMap.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%

classdef tagMap < hgsetget
    
    properties (Access = private)
        Field                % Name of field for this group of tags
        Primary              % True if primary field, false if otherwise
        TagMap               % Map for matching value codes
    end % private properties
    
    methods
        function obj = tagMap(varargin)
            % Constructor parses parameters and sets up initial data
            parser = inputParser;
            parser.addParamValue('Field', 'type', ...
                @(x) (~isempty(x) && ischar(x)));
            parser.addParamValue('Primary', true, ...
                @(x) validateattributes(x, {'logical'}, {}));
            parser.parse(varargin{:})
            obj.Field = parser.Results.Field;
            obj.Primary = parser.Results.Primary;
            obj.TagMap = ...
                containers.Map('KeyType', 'char', 'ValueType', 'any');
        end % tagMap constructor
        
        function addValue(obj, tList, varargin)
            % Add the tagList of tags/tag groups to this object based on
            % updateType
            parser = inputParser;
            parser.addRequired('TList', @(x) (~isempty(x) || ...
                isa(x, 'tagList')));
            parser.addParamValue('UpdateType', 'merge', ...
                @(x) any(validatestring(lower(x), ...
                {'Update', 'Replace', 'Merge', 'None'})));
            parser.addParamValue('PreservePrefix', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
            parser.parse(tList, varargin{:});
            p = parser.Results;
            newStruct = tList;
            if isa(tList, 'tagList')
                newStruct = tList.getStruct();
            end
            
            theKey = newStruct.code();
            
            % Does this value exist in this object?
            if ~obj.TagMap.isKey(theKey) && strcmpi('Merge', p.UpdateType)
                theValue = newStruct.tags();
            elseif obj.TagMap.isKey(theKey) && ...
                    (strcmpi('Merge', p.UpdateType) || ...
                    strcmpi('Update', p.UpdateType))
                oldTList = obj.TagMap(theKey);
                oldStruct = oldTList.getStruct();
                theValue = merge_taglists(newStruct.tags, ...
                    oldStruct.tags, p.PreservePrefix);
            elseif obj.TagMap.isKey(theKey) && strcmpi('Replace', ...
                    p.UpdateType)
                theValue = merge_taglists(newStruct.tags, '', ...
                    p.PreservePrefix);
            else
                return;
            end
            t = tagList(theKey);
            if ischar(theValue)
                t.add(theValue);
            else
                for k = 1:length(theValue)
                    t.add(theValue{k});
                end
            end
            obj.TagMap(theKey) = t;
        end % addValue
        
        function newMap = clone(obj)
            % Clone this tagMap object by making a copy of the map
            newMap = tagMap();
            newMap.Field = obj.Field;
            values = obj.TagMap.values;
            tMap = newMap.TagMap;
            for k = 1:length(values)
                tMap(values{k}.getCode()) = values{k}.clone();
            end
            newMap.TagMap = tMap;
        end % clone
        
        function field = getField(obj)
            % Return the field name corresponding to this tagMap
            field = obj.Field;
        end % getField
        
        function jString = getJson(obj)
            % Return a JSON string version of the tagMap object
            jString = savejson('', obj.getStruct());
        end % getJson
        
        function jString = getJsonValues(obj)
            % Return a JSON string version of the tagList object
            jString = tagMap.values2Json(obj.TagMap.values);
        end % getJsonValues
        
        function eCodes = getCodes(obj)
            % Return the unique codes for this map
            eCodes = obj.TagMap.keys();
        end % getLabels
        
        function primary = getPrimary(obj)
            % Return true if a primary field, false if otherwise
            primary = obj.Primary;
        end % getPrimary
        
        function thisStruct = getStruct(obj)
            % Return this object in structure form
            thisStruct = struct('field', obj.Field, 'values', ...
                obj.getValueStruct());
        end % getStruct
        
        function value = getValue(obj, code)
            % Return the value structure corresponding to specified code
            if obj.TagMap.isKey(code)
                value = obj.TagMap(code);
            else
                value = '';
            end
        end % getValue
        
        function values = getValues(obj)
            % Return the values of this tagMap as a cell array of
            % structures
            values = obj.TagMap.values;
        end % getValues
        
        function eStruct = getValueStruct(obj)
            % Return the values of this tagMap as a structure array
            values = obj.TagMap.values;
            if isempty(values)
                eStruct = '';
            else
                nValues = length(values);
                eStruct(nValues) = values{nValues}.getStruct();
                for k = 1:nValues - 1
                    eStruct(k) = values{k}.getStruct();
                end
            end
        end % getValueStruct
        
        function merge(obj, mTags, updateType, preservePrefix)
            % Combine the tagMap object info with this one
            if isempty(mTags)
                return;
            end
            field = mTags.getField();
            if ~strcmpi(field, obj.Field)
                return;
            end
            values = mTags.getValues();
            for k = 1:length(values)
                obj.addValue(values{k}, 'UpdateType', updateType, ...
                    'PreservePrefix', preservePrefix);
            end
        end % merge
        
    end % public methods
    
    methods(Static = true)
        
        function values = json2Values(json)
            % Converts a JSON values string to a structure or empty
            if isempty(json) || length(loadjson(json)) < 1
                values = [];
                return;
            else
                eStruct = loadjson(json);
                for a = 1:length(eStruct)
                    newTagList = tagList(eStruct(a).code);
                    tags = eStruct(a).tags;
                    if ischar(tags)
                        newTagList.add(tags);
                    else
                        for b = 1:length(tags)
                            if ischar(tags{b}) && all(size(tags{b}) > 1)
                                tags{b} = strtrim(mat2cell(tags{b}, ...
                                    ones(1, size(tags{b}, 1)), ...
                                    size(tags{b}, 2)))';
                            end
                            newTagList.add(tags{b});
                        end
                    end
                    values(a) = newTagList; %#ok<AGROW>
                end
            end
        end % json2Values
        
        function eText = values2Json(values)
            % Convert a value structure array to a JSON string
            if isempty(values)
                eText = '';
            else
                eText = tagList.tagList2Json(values{1});
                for k = 2:length(values)
                    eText = [eText ',' ...
                        tagList.tagList2Json(values{k})]; %#ok<AGROW>
                end
            end
            eText = ['[' eText ']'];
        end % values2Json
        
    end % static method
    
end % tagMap