# book.perl by Ross Moore <ross@mpce.mq.edu.au>  09-14-97
#
# Extension to LaTeX2HTML V97.1 to support the "book" document class
# and standard LaTeX2e class options.
#
# Change Log:
# ===========

package main;


# Suppress option-warning messages:

sub do_book_a4paper{}
sub do_book_a5paper{}
sub do_book_b5paper{}
sub do_book_legalpaper{}
sub do_book_letterpaper{}
sub do_book_executivepaper{}
sub do_book_landscape{}
sub do_book_final{}
sub do_book_draft{}
sub do_book_oneside{}
sub do_book_twoside{}
sub do_book_openright{}
sub do_book_openany{}
sub do_book_onecolumn{}
sub do_book_twocolumn{}
sub do_book_notitlepage{}
sub do_book_titlepage{}
sub do_book_openbib{}

sub do_book_10pt{ $LATEX_FONT_SIZE = '10pt' unless $LATEX_FONT_SIZE; }
sub do_book_11pt{ $LATEX_FONT_SIZE = '11pt' unless $LATEX_FONT_SIZE; }
sub do_book_12pt{ $LATEX_FONT_SIZE = '12pt' unless $LATEX_FONT_SIZE; }

sub do_book_leqno{ $EQN_TAGS = 'L'; }
sub do_book_reqno{ $EQN_TAGS = 'R'; }
sub do_book_fleqn{ $FLUSH_EQN = 1; }

sub do_cmd_thepart {
    join('', &do_cmd_Roman("${O}0${C}part${O}0$C"), ".", @_[0]) }

sub do_cmd_thechapter {
    join('', &do_cmd_arabic("${O}0${C}chapter${O}0$C"), ".", @_[0]) }


sub do_cmd_thesection {
    join('',&translate_commands("\\thechapter")
	, &do_cmd_arabic("${O}0${C}section${O}0$C"), @_[0]) }

sub do_cmd_thesubsection {
    join('',&translate_commands("\\thesection")
	,"." , &do_cmd_arabic("${O}0${C}subsection${O}0$C"), @_[0]) }

sub do_cmd_thesubsubsection {
    join('',&translate_commands("\\thesubsection")
	,"." , &do_cmd_arabic("${O}0${C}subsubsection${O}0$C"), @_[0]) }

sub do_cmd_theparagraph {
    join('',&translate_commands("\\thesubsubsection")
	,"." , &do_cmd_arabic("${O}0${C}paragraph${O}0$C"), @_[0]) }

sub do_cmd_thesubparagraph {
    join('',&translate_commands("\\theparagraph")
	,"." , &do_cmd_arabic("${O}0${C}subparagraph${O}0$C"), @_[0]) }


&addto_dependents('chapter','equation');
&addto_dependents('chapter','footnote');
&addto_dependents('chapter','figure');
&addto_dependents('chapter','table');

sub do_cmd_theequation {
    local($chap) =  &translate_commands("\\thechapter");
    join('', (($chap =~ /^(0\.)?$/)? '' : $chap)
        , &do_cmd_arabic("${O}0${C}equation${O}0$C"), @_[0]) }

sub do_cmd_thefootnote {
    local($chap) =  &translate_commands("\\thechapter");
    join('', (($chap =~ /^(0\.)?$/)? '' : $chap)
        , &do_cmd_arabic("${O}0${C}footnote${O}0$C"), @_[0]) }

sub do_cmd_thefigure {
    local($chap) =  &translate_commands("\\thechapter");
    join('', (($chap =~ /^(0\.)?$/)? '' : $chap)
        , &do_cmd_arabic("${O}0${C}figure${O}0$C"), @_[0]) }

sub do_cmd_thetable {
    local($chap) =  &translate_commands("\\thechapter");
    join('', (($chap =~ /^(0\.)?$/)? '' : $chap)
        , &do_cmd_arabic("${O}0${C}table${O}0$C"), @_[0]) }

# JOS 2025: Implement frontmatter/mainmatter to fix chapter counter sync with LaTeX
# In frontmatter, chapter counter increments but chapters are unnumbered in LaTeX
# In mainmatter, chapter counter is reset so numbered chapters start at 1
sub do_cmd_frontmatter {
    local($_) = @_;
    # Nothing special needed - chapters will increment but that's ok
    # since mainmatter will reset
    $_;
}

sub do_cmd_mainmatter {
    local($_) = @_;
    # Reset the chapter counter to 0 so next chapter is 1
    # This is what LaTeX does when entering mainmatter
    $global{'chapter'} = 0;
    # Also reset dependent counters (equation, figure, table, footnote)
    $global{'eqn_number'} = 0;
    $global{'figure'} = 0;
    $global{'table'} = 0;
    $global{'footnote'} = 0;
    $_;
}

sub do_cmd_backmatter {
    local($_) = @_;
    # Backmatter chapters are unnumbered, but we don't need special handling
    # since the chapter counter will just continue
    $_;
}

1;	# Must be last line

