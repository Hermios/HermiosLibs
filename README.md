# *_Please send any request to Github (See Source URL!)_*
This mod provides a list of tools that can be used for other mods as well.  
In the Prototype Stage:  
- createdata(type,name_to_clone,new_name, specific_data_to_update,is_invisible):
Create a new data (item,prototype etc.) based on existing data. In the new data, some specific elements (like name, replaced by, icons etc.) are automatically udpated
  - type: type of the cloned data, and of the new data
  - name_to_clone: name of the cloned data
  - new_name: name of the new data
  - specific_data_to_update (optional): table that contains all elements to update specifically (for example, a new length of wire for poles)
  - is_invisible (optional): if true, specific parameters of the new data are hardcoded to ensure that the element is not visible. Can apply to items or to prototypes.

In the Runtime Stage:  
- calculate distance between 2 objects
- compare data when comparator is string (>,<,=...)
- Connect all wires (copper, green, red) between 2 entities
- Get unitid of element (entity or train)

Lua optimizations:
- has_value(array, value): Check if array has specified value
- get_first_key(dictionary): Get first index from a dictionary
- get_index(dictionary,value): Find the index for this value in the dictionary
- remove_value(dictionary,value): Remove element from a table based on its value
- string.starts(str,startstr): Check if this __str__ starts with __startsstring__
- string.ends(str,endstr): Check if this __str__ ends with __endstr__ 
- string.split(str,sep): Split the __str__ based on separator __sep__