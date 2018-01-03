% This function checks the number of group brackets in a HED string.
% Unequal opening and closing brackets will generate an error.
%
% Usage:
%
%   >>  errors = checkgroupbrackets(hedString)
%
% Input:
%
%   hedString
%                   A HED string. 
%
% Output:
%
%   errors
%                   A string containing the validation errors.
%
% Copyright (C) 2012-2016 Thomas Rognon tcrognon@gmail.com,
% Jeremy Cockfield jeremy.cockfield@gmail.com, and
% Kay Robbins kay.robbins@utsa.edu
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

function errors = checkgroupbrackets(hedString)
errorType = 'bracket';
errors = '';
numberOfOpeningBrackets = length(strfind(hedString, '('));
numberOfClosingBrackets = length(strfind(hedString, ')'));
if numberOfOpeningBrackets ~= numberOfClosingBrackets
    errors = generateerror(errorType, numberOfOpeningBrackets, ...
        numberOfClosingBrackets, [], []);
end % checkgroupbrackets