package Mplayer::m;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(play);
our $VERSION = '0.03';

#absolutely essential modules
use strict;
use warnings;
use Carp;
use File::Slurp;
use File::Find;
use List::MoreUtils qw(uniq);
use File::Basename;

my (@m,$m,@allfolder,@folder,$USER,@allformat,@format,$format,$folder,@match,@allmatch,$match,$style,$i,$choice,@allchoice,$allargv,$allchoice,$directory,$shuffle,@check,$check,@data,@both);

#getting user name
$USER=$ENV{USER};
sub play {
    
    #erasing .list file and reading settings file .m
    if(-f "/home/$USER/.m"){
	write_file("/home/$USER/.list");
	@m=read_file("/home/$USER/.m");
    }else{
	#for creating config file .m in $ENV{HOME}/
	@data="#add all paths to your folders after 'FOLDER:' separated by space\nFOLDER:\n\n#all the formats to be played after 'FORMAT:' separated by space\n#popular audio formats include 'mp3 wav flac wma ra rm ram ogg mid m4a'\n#popular video formats include 'mov avi divx mpeg mpg m4p flv wmv'\nFORMAT:mp3 wav flac wma ra rm ram ogg mid m4a\n\n#put 'off' to disable shuffle after 'SHUFFLE:'\nSHUFFLE:on";
	write_file("/home/$USER/.m",@data);
    }
    #processing data from .m file
  foreach $m(@m){
      $m =~ s/\s+$//;
      $m=~ s/\s+/ /;
      if($m=~/^FOLDER:/){
	  @allfolder=split(/:/,$m);
	  if($allfolder[1]){
	      @folder=split(/ /,$allfolder[1]);
	  }else{
	      carp "Error:no FOLDER: provided in /home/$ENV{USER}/.m" and exit;
	  }
      }
      if($m=~/^FORMAT:/){
	  @allformat=split(/:/,$m);
	  if($allformat[1]){
	      @format=split(/ /,$allformat[1]);
	      foreach $format(@format){
		  $format="$format\$";
	      }
	  }else{
	      carp "Error:no FORMAT: provided in /home/$ENV{USER}/.m" and exit;
	  }
	  $format=join('|',@format);
      }
      if($m=~/^SHUFFLE:/){
	  @check=split(/:/,$m);
	  if($check[1] ne 'off'){
	      $shuffle='-shuffle';
	  }
      }
  }
    
    #to the real program
    #folders matching single keyword
    if($ARGV[0] and $ARGV[0] eq '-f'){
	shift (@ARGV);
	if(@ARGV==0){
	    @ARGV=".";
	}
	foreach $folder(@folder){
	    chomp($folder);
	    find (\&file,"$folder/");
	}
	@match=uniq(@allmatch);
	if(!@match){print "sorry ..no match found\n";exit}
	print "\n";
	foreach $match(@match){
	    $style=$match;
	    ++$i;
	    print "\e[1;35m$i\e[0m $style";
	}
	print "\n";
	$choice=<STDIN>;
	chomp($choice);
	if($choice){
	    @allchoice=split(/ /,$choice);
	    foreach $allchoice(@allchoice){
		if($allchoice=~/-/){
		    @both=split(/-/,$allchoice);
		    if(!$both[0]){$both[0]=1}
		    if(!$both[1]){$both[1]=@match}
		    while($both[1] >= $both[0]){
			find (\&directory,"$match[$both[0]-1]");
			$both[0]++;
		    }
		}else{
		    find(\&directory,"$match[$allchoice-1]");
		}
	    }
	}else{
	    foreach $match(@match){
		find(\&directory,"$match");
	    }
	}
	exec ("mplayer $shuffle -playlist /home/$USER/.list");
    }
    #for folders with multiple keywords
    #for folders with multiple keywords
    elsif($ARGV[0] and $ARGV[0] eq '-fs'){
	shift (@ARGV);
	if(@ARGV==0){
	    @ARGV=".";
	}
	$allargv=join('|',@ARGV);
	foreach $folder(@folder){
	    chomp($folder);
	    find (\&file_s,"$folder/");
	}
	@match=uniq(@allmatch);
	if(!@match){print "sorry ..no match found";exit}
	print "\n";
	foreach $match(@match){
	    $style=$match;
	    ++$i;
	    print "\e[1;35m$i\e[0m $style";
	}
	print "\n";
	$choice=<STDIN>;
	chomp($choice);
	if($choice){
	    @allchoice=split(/ /,$choice);
	    foreach $allchoice(@allchoice){
		if($allchoice=~/-/){
		    @both=split(/-/,$allchoice);
		    if(!$both[0]){$both[0]=1}
		    if(!$both[1]){$both[1]=@match}
		    while($both[1] >= $both[0]){
			find (\&directory,"$match[$both[0]-1]");
			$both[0]++;
		    }
		}else{
		    find(\&directory,"$match[$allchoice-1]");
		}
	    }
	}else{
	    foreach $match(@match){
		find(\&directory,"$match");
	    }
	}
	exec ("mplayer $shuffle -playlist /home/$USER/.list");
	#play all songs
    }elsif(!@ARGV){
	foreach $folder(@folder){
	    chomp($folder);
	    find (\&all,"$folder/");
	}
	exec ("mplayer $shuffle -playlist /home/$USER/.list");
	#play songs matching keyword
    }elsif($ARGV[0] and $ARGV[0] eq '-s'){
	shift (@ARGV);
	if(@ARGV==0){
	    @ARGV=".";
	}
	$allargv=join('|',@ARGV);
	foreach $folder(@folder){
	    find (\&song_s,"$folder/");
	}
	exec ("mplayer $shuffle -playlist /home/$USER/.list");
    }elsif($ARGV[0] and $ARGV[0] eq ('-h' or '--help')){
	#help option
	print "Usage:
      m [options] key word [...]

      options:
          -s          search files matching multiple key words
          -f          search folders matching keyword
          -fs         search folders matching multiple keywords
          -h          This help message
";
    }else{
      #play songs matching multiple keywords
	foreach $folder(@folder){
	    chomp($folder);
	    find (\&song,"$folder/");
	}
	if(-z "/home/$USER/.list"){print "sorry ..no match found\n";exit}
	exec ("mplayer $shuffle -playlist /home/$USER/.list");
    }
    
}

######

sub song{
    if($_=~/@ARGV/i and $_=~/$format/i){
	append_file("/home/$USER/.list","$File::Find::name\n");
    }
}

sub song_s{
    if($_=~/$allargv/i and $_=~/$format/i){
	append_file("/home/$USER/.list","$File::Find::name\n");
    }
}

sub directory{
    if($_=~/$format/i){
	append_file("/home/$USER/.list","$File::Find::name\n");
    }
}

sub all{
    if($_=~/$format/i){
	append_file("/home/$USER/.list","$File::Find::name\n") if -f;
    }
}

sub file{
    if($_=~/$format/i){
	$directory=dirname($File::Find::name);
	if($directory=~/@ARGV/i){
	    push (@allmatch,$directory);
	}
    }
}

sub file_s{
    if($_=~/$format/i){
	$directory=dirname($File::Find::name);
	if($directory=~/$allargv/i){
	    push (@allmatch,$directory);
	}
    }
}


1;
__END__

=head1 NAME

Mplayer::m - seek and play

=head1 SYNOPSIS

  #to play all files
  m

  #to play all files matching key word ('key word here' matching audio/video files)
  m key word here

  #to play all files matching several keywords('key' or 'word' or 'here' matching audio/video files)
  m -s key word here

  #to list all folders
  m -f

  #to find and play files from a folder matching a keyword ('key word here' matching folders)
  m -f key word here

  #to find and play files matching several keywords('key' or ' word' or 'here' matching folders)
  m -fs key word here

  #help
  m -h

=head1 DESCRIPTION

A cool way for finding audio/video files and play with mplayer.

=head1 METHOD

Run 'm' once in terminal after installing the module.This will create '.m' in your Home folder which will contain folder paths and formats to be searched.Add folder paths to .m (see 'Content of '.m' file below).After this just execute 'm' again and Enjoy!!

When using m with folder options ( -f or -fs ) it will show a list of folder with path duly numbered.For example

  #m -f rammstein
  
   1 /media/Music/Rammstein-Greatest Hits/CD1
   2 /media/Music/Rammstein-Greatest Hits/CD2
   3 /media/Music/Rammstein/some collection
   4 /home/mani/Downloads/Rammstein-Disography
   5 /home/mani/Downloads/Rammstein
  
Now select any number of folder listed by entering corresponding number on the left side seperated by space and then pressing Enter.For example

  #1 3

will play files in  '/media/Music/Rammstein-Greatest Hits/CD1'   &   '/media/Music/Rammstein/some collection'

 #1 3-5

will play files corresponding to 1,3,4,5


 # 2-

will play files corresponding to 2 and folders after it (i.e 2,3,4 and 5)

 #-3

will play files corresponding to 3 and folders before it (i.e 1,2 and 3)

If no folder number is provided, all files in all folders shown will be played (i.e 1,2,3,4 and 5) 

=head2 Content of '.m' file

  #add all paths to your folders after 'FOLDER:' separated by space
  FOLDER:

  #all the formats to be played after 'FORMAT:'
  #popular audio formats include 'mp3 wav flac wma ra rm ram ogg mid m4a'
  #popular video formats include 'mov avi divx mpeg mpg m4p flv wmv'
  FORMAT:mp3 wav flac wma ra rm ram ogg mid m4a

  #put 'off' to disable shuffle after 'SHUFFLE:'
  SHUFFLE:on

Make sure you fill 'FOLDER:' option eg. FOLDER:/home/mani/Downloads  /media/Entertainment

By defualt for 'FORMAT:' option, 'mp3 wav flac wma ra rm ram ogg mid m4a' are included.

By default 'SHUFFLE:' is on

=head2 EXPORT

play

=head1 AUTHOR

Dileep Mani, E<lt>dileepmani@gmail.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Dileep Mani

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
