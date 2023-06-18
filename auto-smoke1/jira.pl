use JIRA::Client;
use Data::Dumper;

sub jira{
%mapdata = ('Build Flash' => '[OTA_01] flashall','Boot Version Check'  => 'test','Adb enumeration Test' =>  '[ADB_01] adb connectivity','Home Screen Test'  =>  '[FWGEN_FS_04] Home Screen','Display Check'  => 'Suspend/Resume','Battery Test' => '[WC_02] Wall Charging','BT On/Off Test' => '[BT_001]Bluetooth Enable/disable','Airplane Mode Check' => '[FWTEL_FS_23] Aeroplane mode OFF','WiFi On/Off Test' => '[WiFi_001] Enable / disable wifi and check for Access point list','WiFi AP Connect Test' => '[WiFi_001] Enable / disable wifi and check for Access point list','Data browsing Test' => '[WiFi_002]Connect to access point and Check internet connection through browsing','Camera Image Test' => '[MM_cam_01] Camera Launch','Camera Video Test' => '[MM_cam_01] Camera Launch','Audio Test' => '[MM_audio_01] Play Audio mp3 format','Video Test' => '[MM_video_01] Play Video mp4 format','Kernel Version Check' => 'test','Kernel Suspend Resume Check' => 'test','Boot Animation Test' => '[FWGEN_FS_11] Boot Animation','Boot to Bootloader Test' =>  'test','SMS Test' =>  '[COREAPP_MESSAGE_FS_10] Send Message','MO Call Check' => '[FWTEL_FS_36] Outgoing call','MT Call Check' => '[FWTEL_FS_37] Incoming call  and Answer');

my $filecheck = `[ -f /home/smoke/smoketest/logs/2*.txt ] && echo 'File exist' || echo 'File does not exist'`;
if ($filecheck == "File exist")
{
   my $filename = `ls /home/smoke/smoketest/logs/2*.txt`;
   my $str = "FAIL";
   my $buildID = @_;
   my $issue;
   my $jiraissue;
   open(my $fh, $filename) or die "Could not open file '$filename' $!";
   while (my $row = <$fh>) 
   {
       chomp $row;
       if($row =~ m/BuildNumber:/){
       ($rest,$buildID) = split(/:/, $row, 2);
      }
      elsif ($row =~ m/FAIL/)
      {
         my($first, $rest) = split(/-/, $row, 2);
         my($rest, $first) = split(/ /, $first, 2);
         chop($first);
         my $check=$mapdata{$first};
         #print "check is $check\n";
         $issue = check_jira($check);
         print $issue;
         if($issue) {
            print "$check failed at smoke test and $issue-jira existing for failure\n";
            update_jira($issue,$check,$buildID);
         }
         else{
           print "No Jira available for failure-$check\n";
           print "Creating the Jira...!\n";
           #create_jira($check);
           $jiraissue = check_jira($check);
           if($jiraissue) {
              print "Jira created - $jiraissue\n";        
           }
           else{
               print "no checking"
           }
         }
      }
     }
 
}
else{
  print "Smoke test results not available";
}
}
sub update_jira {
  #my $filename="/home/smoke/smoketest/logs/logcat*.txt";
  my $filename=`ls /home/smoke/smoketest/logs/logcat*.txt`;
  print $buildID;
  my ($key,$testcase,$buildID) = @_;
  my $jira = JIRA::Client->new('https://jira.innominds.com/', 'cdci', '4tVg\y9Vyf');
  $jira->addComment($key, "$testcase reproduced in MPAA1-$buildID");
  if($jira){
     print "added comment for $key\n";     
  }
  #$jira->attach_files_to_issue('$key','$filename'); 
}
sub check_jira {
   my ($check_jira) = @_;
   my $search,$rest;
   print "in side $check_jira\n";
   if($check_jira =~ m/ /){
     ($rest, $search) = split(/ /, $check_jira, 2);
   }
   else{
      $search = $check_jira;
   }
   my $jira = JIRA::Client->new('https://jira.innominds.com/', 'cdci', '4tVg\y9Vyf');
   my $filter = 'IndraM_Smoke';
   $jira->set_filter_iterator($filter);
   my $issues = $jira->getIssuesFromFilter($jira->{iter}->{id});
   my $issueid;
   my $desc;
   foreach my $k (@{$issues}) {
       $issueid = $k->{key};
       $desc = $k->{summary};
       my $jirastatus = $k->{status};
       if($desc =~ m/$search/){
          #print $issueid;
          return $issueid;         
       }
}
}

sub create_jira {
  my ($create_jira) = @_;
  #my $jira = JIRA::Client->new('https://jira.innominds.com', 'cdci', '4tVg\y9Vyf');
  my $jira = JIRA::Client->new('https://jira.innominds.com/', 'cdci', '4tVg\y9Vyf');  
  my $issues = $jira->create_issue(
    {
      project => 'CDSWM',
      type => 'Defect',
      summary => "$create_jira failed at smoke test",
      components => ['CM-Integ'],
      custom_fields => {customfield_10202 => 'Blocker', customfield_11709 => 'QA Team'},
      priority => 'P0 - Immediate',
      Labels => ['IndraM_Smoke'],
      #custom_fields => {customfield_10002 => 'IndraM_Smoke'},
      #priority => 'P0 - Immediate'
    }
  );
   my $jiraissue = check_jira($create_jira);
   if($jiraissue) {
        print "Jira created - $jiraissue\n";
  }
}
sub attach_jira {
   my ($issue,$filepath) = @_;
    $jira->attach_files_to_issue('$issue','$filepath');
}
1;
