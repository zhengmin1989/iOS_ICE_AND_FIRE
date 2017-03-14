#Local Privilege Escalation for macOS 10.12.2 via mach_voucher and XNU port Feng Shui

 * Exp: https://github.com/zhengmin1989/macOS-10.12.2-Exp-via-mach_voucher

 * Write up:  
         
      1. Chinese Version: coming soon.  
      
      2. English Version: https://jaq.alibaba.com/community/art/show?articleid=781
 
 * by Min(Spark) Zheng (twitter@SparkZheng, weibo@蒸米spark)

 * Compile:  
  clang -framework IOKit -framework Foundation -framework CoreFoundation -pagezero_size 0x16000 exp.m -o exp

 * Special thanks to qwertyoruiop, ian beer, aimin pan, jingle, etc.
 
 * Reference:
 
      1. Yalu 102: https://github.com/kpwn/yalu102
         
      2. https://bugs.chromium.org/p/project-zero/issues/detail?id=1004
 
