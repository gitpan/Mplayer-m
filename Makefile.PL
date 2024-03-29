use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
	      NAME              => 'Mplayer::m',
	      VERSION_FROM      => 'lib/Mplayer/m.pm', # finds $VERSION
	      PREREQ_PM         => {File::Slurp=>0,File::Find=>0,List::MoreUtils=>0,File::Basename=>0}, # e.g., Module::Name => 1.1
	      INST_SCRIPT        =>'bin/',
	      ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
	       (ABSTRACT_FROM  => 'lib/Mplayer/m.pm', # retrieve abstract from module
		AUTHOR         => 'Dileep Mani <dileepmani@gmail.com>') : ()),
	     );
