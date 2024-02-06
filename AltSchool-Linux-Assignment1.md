# AltSchool-Linux-Assignment1

* Your login name: altschool i.e., home directory /home/altschool. The home directory contains the following sub-directories: code, tests, personal, misc Unless otherwise specified, you are running commands from the home directory.
![login name: AltSchool with home directory and sub-directory](/images/LoginName.png)

* Change directory to the tests directory using absolute pathname
   ##### command - cd /home/AltSchool/tests
![Absolute Pathname](/images/AbsolutePathname.png)

* Change directory to the tests directory using relative pathname
   ##### command - cd ./tests
![Relative Pathname](/images/RelativePathname.png)

* Use echo command to create a file named fileA with text content ‘Hello A’ in the misc directory
![Create file using echo command](/images/EchoCommand.png)

* Copy contents of fileA into fileC
  
![Copy Contents of FileA To FileC](/images/CopyContentofFileAToFileC.png)


* Create an empty file named fileB in the misc. Move contents of fileB into fileD
![Create FileB and Move contents to FileD](/images/CreateAndMoveFileBToFileD.png)

* Create a tar archive called misc.tar for the contents of misc directory
    ##### command = tar -cvf misc.tar
![Tar Archive File](/images/TarArchive.png)

* Compress the tar archive to create a misc.tar.gz file
  ##### command = gzip misc.tar
![Compress Tar Archive File](/images/CompressTarArchive.png)

* Create a user and force the user to change his/her password upon login
##### command = sudo useradd username 
 ##### command sudo chage -d 0 username
![Create User and Force User to Change Password Upon Login](/images/ForceUserToChangePasswdUponLogin.png)

* Lock a users password
  ##### command = sudo passwd -l username
![LockUserPassword](/images/LockUserPassword.png)

* Create a user with no login shell
  ##### command = sudo useradd -s /usr/sbin/nologin username
![NoLoginUser](/images/NoLoginUser.png)

* Disable password based authentication for ssh
  ##### command = sudo vi /etc/ssh/sshd_config
![DisablePasswordForSSH](/images/DisablePasswordForSSh.png)

* Disable root login for ssh
##### command = sudo vi /etc/ssh/sshd_config
![DisableRootLoginForSSH](/images/DisableRootLoginForSSH.png)
