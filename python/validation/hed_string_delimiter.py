'''
This module is used to split HED tags into dictionaries.

Created on Nov 15, 2017

@author: Jeremy Cockfield

'''


import copy;


class HedStringDelimiter:
    DELIMITER = ',';
    OPENING_GROUP_CHARACTER = '(';
    CLOSING_GROUP_CHARACTER = ')';

    def __init__(self, hed_string):
        self.hed_string = hed_string;
        self.tag_set = self._split_hed_string();

    def get_tag_set(self):
        """Gets the tag_set field.

        Parameters
        ----------
        Returns
        -------
        set
            A set containing the individual tags and tag groups in the hed string. Nested tag groups are not split.

        """
        return self.tag_set

    def _split_hed_string(self):
        """Splits the tags and non-nested groups in a hed string based on a delimiter. The default delimiter is a comma.

        Parameters
        ----------
        Returns
        -------
        set
            A set containing the individual tags and tag groups in the hed string. Nested tag groups are not split.

        """
        tag_set = set();
        number_of_opening_parentheses = 0;
        number_of_closing_parentheses = 0;
        current_tag = '';
        for character in self.hed_string:
            if character == HedStringDelimiter.OPENING_GROUP_CHARACTER:
                number_of_opening_parentheses += 1;
            if character == HedStringDelimiter.CLOSING_GROUP_CHARACTER:
                number_of_closing_parentheses += 1;
            if number_of_opening_parentheses == number_of_closing_parentheses and character == \
                    HedStringDelimiter.DELIMITER:
                tag_set.add(current_tag.strip());
                current_tag = '';
            else:
                current_tag += character;
        tag_set.add(current_tag.strip());
        return tag_set;

    def get_top_level_tags(self):
        """Gets the top-level tags from a hed string. All group tags will be removed.

        Parameters
        ----------
        Returns
        -------
        set
            A set containing the top level tags.

        """
        groups_to_remove = [];
        top_level_tag_set = copy.deepcopy(self.tag_set);
        for top_level_tag_or_group in self.tag_set:
            if top_level_tag_or_group.startswith(HedStringDelimiter.OPENING_GROUP_CHARACTER) and \
               top_level_tag_or_group.endswith(HedStringDelimiter.CLOSING_GROUP_CHARACTER):
                top_level_tag_set.remove(top_level_tag_or_group);
        top_level_tag_set = self.remove_elements_from_set(top_level_tag_set, groups_to_remove);
        return top_level_tag_set;

if __name__ == '__main__':
    hed_string = 'tag1,(tag2,tag5,(tag1),tag6),tag2,(tag3,tag5,tag6),tag3';
    hed_string_delimiter = HedStringDelimiter(hed_string);
    tags = hed_string_delimiter.get_top_level_tags();
    print(tags);