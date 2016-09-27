#Local privilege escalation for OS X 10.11.6 via PEGASUS

*  Exp: https://github.com/zhengmin1989/OS-X-10.11.6-Exp-via-PEGASUS


*  Write up:  
        1. Chinese Version: https://jaq.alibaba.com/community/art/show?articleid=531  
        2. English Version: https://jaq.alibaba.com/community/art/show?articleid=532  

 * by Min(Spark) Zheng (twitter@SparkZheng, weibo@蒸米spark)

 * Note:   
         1. If you want to test this exp, you should not install Security Update 2016-001 
            (like iOS 9.3.5 patch for PEGASUS).  
         2. I hardcoded a kernel address to calcuate kslide, it maybe different on your mac.  

 
 * Compile:  
   clang -framework IOKit -framework Foundation -framework CoreFoundation -m32 -Wl,-pagezero_size,0 -O3 exp.m lsym.m -o exp

 * Run the exp:  
    MacBookPro:PEGASUS zhengmin$ ./exp   
    getting kslide...  
    kslide=0x8e00000  
    building the rop chain...  
    exploit the kernel...  
    sh-3.2# whoami  
    root  
    sh-3.2# uname -a  
    Darwin MacBookPro 15.6.0 Darwin Kernel Version 15.6.0: Thu Jun 23 18:25:34 PDT 2016; root:xnu-3248.60.10~1/RELEASE_X86_64 x86_64  


 * Special thanks to proteas, qwertyoruiop, windknown, aimin pan, jingle, liangchen, qoobee, 
   cererdlong, eakerqiu, etc.
 
 * Reference:   
              1. http://blog.pangu.io/cve-2016-4655/  
              2. https://sektioneins.de/en/blog/16-09-02-pegasus-ios-kernel-vulnerability-explained.html  
              3. https://bazad.github.io/2016/05/mac-os-x-use-after-free/  
              4. https://github.com/kpwn/tpwn  
   
