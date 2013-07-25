use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
my @data;

#for creating config file .m in $ENV{HOME}/
@data="#add all paths to your folders after 'FOLDER:' separated by space\nFOLDER:\n\n#all the formats to be played after 'FORMAT:' separated by space\n#popular audio formats include 'mp3 wav flac wma ra rm ram ogg mid'\n#popular video formats include 'mov avi divx mpeg mpg m4p flv wmv'\nFORMAT:mp3 wav flac\n\n#put 'off' to disable shuffle after 'SHUFFLE:'\nSHUFFLE:on";
open(DATA,">$ENV{HOME}/.m");
print DATA ("@data");
close(DATA);

WriteMakefile(
	      NAME              => 'Mplayer::m',
	      VERSION_FROM      => 'lib/Mplayer/m.pm', # finds $VERSION
	      PREREQ_PM         => {File::Slurp=>9999.00,File::Find=>1.00,List::MoreUtils=>0,File::Basename=>2.00}, # e.g., Module::Name => 1.1
	      INST_SCRIPT        =>'bin/',
	      ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
	       (ABSTRACT_FROM  => 'lib/Mplayer/m.pm', # retrieve abstract from module
		AUTHOR         => 'Dileep Mani <dileepmani@gmail.com>') : ()),
	     );
