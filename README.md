# Howto Run

1. Download attached file on your PC (ch_cpuinfo_en.tar) / (ch_cpuinfo_kr.tar is file for korean)

2. Upload file to your DSM location (by filestation, sftp, webdav etc....)

3. Connect to ssh by admin account. (dsm > control panel > terminal & snmp > terminal > enable ssh check)

4. Switch user to root:

   > sudo su -
   
   (input admin password)

5. Change directory to where `ch_cpuinfo_en.tar` file is located:

   > cd /volume1/temp

6. Decompress file & check file:

   > tar xvf ch_cpuinfo_en.tar<br>
   > ls -lrt
   
   (check root’s run auth)

7. Run to Binary file

   > ./ch_cpuinfo
 
8. When you execute it, proceed according to the description that is output.

9. Check your DSM’s CPU name, CPU cores at `information center`


# Reference URL

https://xpenology.com/forum/topic/13030-dsm-5x6x-cpu-name-cores-infomation-change-tool


# Change Log

5.1.
   - Use bash change to sh
     > #!/bin/bash
     change to
     > #!/bin/sh

5.0.
   - Update new version (ch_cpuinfo ver 5.0) 2018.10.30
     
     Improved CPU information collection command

     Change to pure core value without applying thread, and For Native H/W users,

     changed to display the number of cpus, the number of cores per cpu, and the number of threads.

     > ex.<br>
     > 1 CPU 1 Core Not support HT ->  1 Core (1 CPU |  1 Thread)<br>
     > 1 CPU 2 Core Support HT ->   2 Cores(1 CPU/2 Cores | 4 Threads)<br>
     > 2 CPU 4 Core Support HT ->   8 Cores(2 CPUs/4 Cores | 16 Threads)

4.0.
   - Update new version (ch_cpuinfo ver 4.0) 2018.09.13

     a. Mobile support (just 6.x / not yet 5.x)

        You can see it when you go into mobile browser or "DS mobile" menu in "DS Finder"

     b. Improved CPU information collection command

        Some dmidecode commands have been found to be missing information and have been improved.(Thanks stefauresi !!! :))

     c. Edited some variable names

        I adjusted some inconsistently coded variables

3.0.
   - Update new version (ch_cpuinfo ver 3.0) 2018.08.26

     I made the tool by adding and improving the function. Please refer to above for how to use it.

     I delete the old version attached files, new version uploaded and attached.

     If you use last version tool, you can use without restore.