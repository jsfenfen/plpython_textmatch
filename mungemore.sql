------
-- An approximation of google refine's fingerprint function. See here: http://code.google.com/p/google-refine/source/browse/trunk/main/src/com/google/refine/clustering/binning/FingerprintKeyer.java
-- This ignores non-ascii characters, which is probably a bad idea 
-- Possible translate functions given in google refine's code for latin1, maybe here if we start with unicode: http://pypi.python.org/pypi/Unidecode/0.04.1
----

CREATE OR REPLACE FUNCTION fingerprint (IN somestring text) RETURNS text AS
$$
    mystring = somestring.lower()
    letterhash = {}
        
    for x in list(mystring):
        ordx = ord(x)    
        if ( (ordx > 47 and ordx < 58) or ( ordx > 96 and ordx < 123) ):
            letterhash[x]=1
        
    result = letterhash.keys()
    result.sort()
    return ''.join(result)
$$
LANGUAGE 'plpythonu' VOLATILE;

----
-- To delete this function use: 
-- drop function fingerprint(text);
----
-- See python's sequencematcher. This returns the longest matching block. 
--
--
--
CREATE OR REPLACE FUNCTION longest_match (IN text1 text, text2 text) RETURNS int AS
$$

import difflib

isjunk=None

# Case insensitive here--not sure it's needed / helpful
s = difflib.SequenceMatcher(isjunk,text1.lower(), text2.lower());

longest_match_length = 0

for opcode, a0, a1, b0, b1 in  s.get_opcodes():
    if opcode == 'equal':
        this_match = s.a[a0:a1]
        this_length = len(this_match)
        if this_length > longest_match_length:
             longest_match_length = this_length

return longest_match_length 
    
$$
LANGUAGE 'plpythonu' VOLATILE;    

-----
-- Erase the function with this command:
--
--# drop function longest_match(text, text);
-------


-----
-- Return the total length of all matching blocks
--
-----

CREATE OR REPLACE FUNCTION total_match (IN text1 text, text2 text) RETURNS int AS
$$

import difflib

isjunk=None

# Case insensitive here--this might not be the right choice
s = difflib.SequenceMatcher(isjunk,text1.lower(), text2.lower());

total_match_length = 0

for opcode, a0, a1, b0, b1 in  s.get_opcodes():
    if opcode == 'equal':
        this_match = s.a[a0:a1]
        this_length = len(this_match)
        total_match_length = total_match_length + this_length

return total_match_length
    
$$
LANGUAGE 'plpythonu' VOLATILE;    

-----
-----
-- Erase the function with this command:
--
--# drop function total_match(text, text);
--

------
-- Return ngrams.  
--
-----

CREATE OR REPLACE FUNCTION ngram (IN somestring text, ngram_length int) RETURNS text AS
$$
mystring = somestring.lower()


b = list(mystring)
chars_array = []

for x in b:
    ordx = ord(x)
        
    # ignore it if it's punctuation or whitespace    
    if ( (ordx > 47 and ordx < 58) or ( ordx > 96 and ordx < 123) ):
        chars_array.append(x)

cleaned_string = "".join(chars_array)
length = len(chars_array)

# can't run ngrams on too short a string:
if (ngram_length >= length):
    return cleaned_string

ngram_hash = {}

for a in range (0, length-ngram_length+1):
    ngram_array = chars_array[a:a+ngram_length]
    this_ngram = "".join(ngram_array)
    ngram_hash[this_ngram]=1

result = ngram_hash.keys()
result.sort()
return ''.join(result)
$$
LANGUAGE 'plpythonu' VOLATILE;