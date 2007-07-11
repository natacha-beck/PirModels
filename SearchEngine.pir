#
# This class is an abstract PirObject class for
# searching an arbitrary genomic element with some
# search engine; subclasses should provided the necessary
# method to implement the search uging the API defined here.
#
#    $Id: SearchEngine.pir,v 1.1 2007/07/11 19:55:18 riouxp Exp $
#
#    $Log: SearchEngine.pir,v $
#    Revision 1.1  2007/07/11 19:55:18  riouxp
#    New project. Initial check-in.
#
#    Added Files:
#        HMMweasel
#        HMMER2SearchEngine.pir LinStruct.pir PotentialResult.pir
#        RawDiskSeqs.pir RawSeq.pir ResultElement.pir SearchEngine.pir
#        SimpleHit.pir SimpleHitList.pir StructElem.pir
#

- PerlClass	PirObject::SearchEngine
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------

rawdiskseqs             single          <RawDiskSeqs>   Must be tied to a file.
tmpworkdir              single          string          Optional
debug                   single          int4            Optional

#name			single		string		A single string
#age			single		int4		A single number
#pet_names		array		string		An array of strings
#pet_ages		array	        int4		An array of numbers
#address		single          <Address>	A single subobject, found in Address.pir
#previous_addresses	array		<Address>	An array of subobjects

- EndFieldsTable

- Methods

# Returns an internal opaque token to be used by SearchSequences().
sub PrepareElementSearch {
    my $self           = shift;
    my $fastamultalign = shift; # The actual multiple alignment in text format, as a single string
    my $id             = shift; # Optional ID for this alignment.
    my $forstrand      = shift; # Optional "+" or "-"; default is both
    die "Method not defined in subclass?!?\n";
    return "elementToken";
}

sub SearchSequences {
    my $self           = shift;
    my $elementToken   = shift; # as returned by PrepareElementSearch
    die "Method not defined in subclass?!?\n";
    my $results = undef;
    return $results;  # A PirObject::SimpleHitList;
}

