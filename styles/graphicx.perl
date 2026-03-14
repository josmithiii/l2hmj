# graphics.perl
#    by Bruce Miller <bruce.miller@nist.gov>
# Support of the graphics.sty standard LaTeX2e package
#    with `standard argument format'
# See graphics-support.perl
# ====================================================================== 
do_require_package('graphics-support');

# Package Options
sub do_graphics_dvips {}
sub do_graphics_draft {} # What'd be the point?
sub do_graphics_final {}
sub do_graphics_hiresbb {}
sub do_graphics_hiderotate { 
  map($GRAPHICS_OPTHIDE{$_}=1, @GRAPHICS_ROTATEOPTS); }
sub do_graphics_hidescale  { 
  map($GRAPHICS_OPTHIDE{$_}=1, @GRAPHICS_SCALEEOPTS); }

# ====================================================================== 
sub do_cmd_includegraphics {
  local($_)=@_;
  my $opt=x_next_optarg();   $opt =~ s/,/ /;
  my $op2=x_next_optarg();   $op2 =~ s/,/ /;
  my $file = x_next_arg();
  my $options;
  if ($op2) {
    # Two optional args: graphics.sty bounding box format [llx,lly][urx,ury]
    $options = "bb=$opt $op2";
  } elsif ($opt && $opt =~ /=/) {
    # Key=value options: graphicx.sty format (width=..., scale=..., etc.)
    $options = $opt;
  } elsif ($opt) {
    # Single numeric optional arg: bounding box upper-right corner
    $options = "bb=0 0 $opt";
  } else {
    $options = '';
  }
  do_includegraphics($file, $options,
     "\\includegraphics".($opt && "[$opt]").($op2 && "[$op2]")."\{$file\}"); }

sub do_cmd_includegraphicsstar {
  local($_)=@_;
  my $opt=x_next_optarg();  $opt =~ s/,/ /;
  my $op2=x_next_optarg();  $op2 =~ s/,/ /;
  my $file = x_next_arg();
  my $options;
  if ($op2) {
    $options = "bb=$opt $op2, clip";
  } elsif ($opt && $opt =~ /=/) {
    $options = "$opt, clip";
  } elsif ($opt) {
    $options = "bb=0 0 $opt, clip";
  } else {
    $options = "clip";
  }
  do_includegraphics($file, $options,
     "\\includegraphics*".($opt && "[$opt]").($op2 && "[$op2]")."\{$file\}"); }

# ====================================================================== 
1;

