# Howto Run

made a video of the how to run ch_cpuinfo.<br>
[![tr_st](http://img.youtube.com/vi/e9I-5srNfNY/0.jpg)](https://youtu.be/e9I-5srNfNY) 

![image](https://user-images.githubusercontent.com/42568682/218249473-f8fe1241-49dd-482c-a0fa-4d673fcfd754.png)

** Online **

1. Connect to ssh by admin account. (dsm > control panel > terminal & snmp > terminal > enable ssh check)

2. Switch user to root:

   > sudo su -
   
   (input admin password)

3. Download ch_cpuinfo.tar with wget

   > wget https://github.com/FOXBI/ch_cpuinfo/releases/download/ch_cpuinfo/ch_cpuinfo.tar

4. Continue Offline step 6.

** Offline **

1. Download attached file on your PC (ch_cpuinfo.tar)

2. Upload file to your DSM location (by filestation, sftp, webdav etc....)

3. Connect to ssh by admin account. (dsm > control panel > terminal & snmp > terminal > enable ssh check)

4. Switch user to root:

   > sudo su -
   
   (input admin password)

5. Change directory to where `ch_cpuinfo.tar` file is located:

   > cd /volume1/temp

6. Decompress file & check file:

   > tar xvf ch_cpuinfo.tar<br>
   > ls -lrt
   > chmod 755 ch_cpuinfo

   (check root’s run auth)

7. Run to Binary file

   > ./ch_cpuinfo<br>
   or<br>
   > ./ch_cpuinfo.sh (If you use busybox in 5.x, you can use it as a source file)
 
8. When you execute it, proceed according to the description that is output.

9. Check your DSM’s CPU name, CPU cores at `information center`


# Reference URL

https://xpenology.com/forum/topic/13030-dsm-5x6x7x-cpu-name-cores-infomation-change-tool


# Reference Screeshot

![Alt text](./github/images/ch_cpuinfo_001.png "new Run Image")

![Alt text](./github/images/ch_cpuinfo_002.png "new Redo Image")

![Alt text](./github/images/ch_cpuinfo_003.png "new Recover Image")

![Alt text](./github/images/mobile_002.png "DSM 6.x Mobile")

![Alt text](./github/images/dsm_7_3622_en.png "DSM Control Pannel")

![Alt text](./github/images/surveillance_001.png "Suveillance Station Control Pannel")