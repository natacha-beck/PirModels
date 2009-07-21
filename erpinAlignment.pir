
#
# This class contain hash of Item List for each RNA model
#

- PerlClass	PirObject::erpinAlignement
- InheritsFrom	PirObject
- FieldsTable

# Field name    		Sing/Array/Hash	Type		    Comments
#---------------------- ---------------	---------------	-----------------------
header                  single          string          header used for alignment title
aliNumber               single          int4            The number of alignment
strand                  single          string          the strand of result
AliStart                single          int4            start of result for ali
AliStop                 single          int4            stop of result for ali
LogStart                single          int4            start of result for log
LogStop                 single          int4            stop of result for log
AcStart                 single          int4            start of Ac element
AcStop                  single          int4            stop of Ac element
AcAa                    single          string          Ac amino acid
AcTriNt                 single          string          Tri nt of Anticodon
evalue                  single          string          evalue of alignment
AliForAli               single          string          alignment used for .ali
HeadForAli              single          string          header used for .ali
AliForLog               single          string          alignment used for .log
HeadForLog              single          string          header used for .log
