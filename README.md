# YPMuPDFDemo
基于第三方框架Mupdf实现了浏览pdf的功能
### 实现页码，切换夜视，分页浏览，涂鸦，删除涂鸦，复制涂鸦等功能
## 2019-07-04
 增加目录
 增加搜索文字
 增加签名
 增加涂鸦前进后退

## 2019-07-19
 修复查询功能卡顿
 考虑多线程安全问题
 分离取图片和文字的功能

## 2019-09-23  
因为这个我编译的包主要是针对真机，这次版本上传了mupdf最新的源文件。有需要的可以自己编译。也欢迎各位提issue。 有问题我们一起探讨。 
  
## 2019-10-09
修复pdf 放大缩小之后字体模糊  
修复pdf不能记住放大缩小的位置
  
#### 版本遗留问题，搜索的时候会有内存泄漏。这个问题我弄了好久，各种内存泄漏工具都用上了。查处了很多Ç方法使用不对的地方，但是还有一些改了就就会闪退的问题

#### 有兴趣的可以联系我一起研究

因为git上传限制，这个版本没有mupdf.a 库。有需要.a库的可以单独私聊我，或者自己去mupdf下载demo，然后走一遍官方demo的bash.sh脚本
之后再自己编译一下就能拿到他的lib库。
联系方式：704835361@qq.com
