#
# This is used in many different contexts to represent
# how a match was found between an element to search
# and a molecular sequence; this object also contains a
# copy of some of the structural information for the element.
#
#    $Id: ResultElement.pir,v 1.4 2008/08/20 19:43:22 riouxp Exp $
#
#    $Log: ResultElement.pir,v $
#    Revision 1.4  2008/08/20 19:43:22  riouxp
#    Added CVS tracking variables.
#
#    Revision 1.3  2007/07/20 17:44:44  riouxp
#    Added support to detect and eliminate results that are
#    substantially the same.
#
#    Revision 1.2  2007/07/18 21:26:20  riouxp
#    Added field "piecenumber". Removed obsolete field "distancewarnings".
#
#    Revision 1.1  2007/07/11 19:55:18  riouxp
#    New project. Initial check-in.
#
#    Added Files:
#        HMMweasel
#        HMMER2SearchEngine.pir LinStruct.pir PotentialResult.pir
#        RawDiskSeqs.pir RawSeq.pir ResultElement.pir SearchEngine.pir
#        SimpleHit.pir SimpleHitList.pir StructElem.pir
#

- PerlClass	PirObject::ResultElement
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
elementId               single          string
elemStart               single          int4
elemStop                single          int4
elemType                single          string

seqStart                single          int4
seqStop                 single          int4
score                   single          string
evalue                  single          string

sequence                single          string

piecenumber             single          int4             When part of a solution in pieces

- EndFieldsTable
- Methods

our $RCS_VERSION='$Id: ResultElement.pir,v 1.4 2008/08/20 19:43:22 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub IsSubstantiallyTheSameAs {
    my $self  = shift;
    my $other = shift || die "Need other object to compare to.\n";

    my $class    = ref($self) ||
        die "This is an instance method.\n";

    die "Other object is not of the same class as self!?\n"
        unless $other->isa($class);

    foreach my $field qw( seqStart seqStop elementId elemStart elemStop elemType sequence piecenumber ) {
        my $v1 = $self->$field();
        my $v2 = $other->$field();
        next     if !defined($v1) && !defined($v2);
        return 0 if !defined($v1) || !defined($v2);
        return 0 if $v1 ne $v2;
    }

    return 1;
}
