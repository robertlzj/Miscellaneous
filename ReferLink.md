流程：

先将内容相同的文件硬链接。
（*硬链接*原生支持*入口*查询（*软链接*仅支持*入口*至*源*的*单向*的*源*查询））

文件**内容** *相同*，文件的**属性**可能*不同*。
文件的**属性**包括<u>创建时间</u>等。

目的：避免重复人工审查文件内容。

流程：

	1. 将内容相同的文件（简称**重复文件**）存储在最近**公共**路径（通常为*父*文件夹，或当在同一文件夹时为此文件夹）下的专用文件夹（如\_storage\_）下，成为**共享**文件。（文件名抽象掉）
 	2. 软链接原路径（***原*文件**）至***共享*文件**。

需求：删除所有实例（入口）。

实现：若*入口*（软链接）指向*源*，则删除源，再扫描所有失效入口，删除入口。

功能、需求：删除时检测是否有其他入口，是仅删除当前活动入口，或删除全部相关入口。

- [x] 问题：移动硬链接文件，是否保持硬链接？
  回答：至少在资源管理器中剪贴-粘贴、拖放移动时，是保持。
- [ ] 问题：检测到文件有其他（硬链接）入口，甚至其他入口被作为软链接的源（如在\_storage\_文件夹下）。

#### **扩展文件属性**

出自[Microsoft Windows 2000 Scripting Guide - Retrieving Extended File Properties | Microsoft Docs](https://docs.microsoft.com/en-us/previous-versions/tn-archive/ee176615(v=technet.10)?redirectedfrom=MSDN)

另见：`objFolder.GetDetailsOf(objFolderItem, column)`中的`column`，[c# - What options are available for Shell32.Folder.GetDetailsOf(..,..)? - Stack Overflow](https://stackoverflow.com/questions/22382010/what-options-are-available-for-shell32-folder-getdetailsof)

#### 过程

[("is" or "whether" or "check" or "assert" or "detect") ("hard link" or "hardlink") autohotkey - Google 搜索](https://www.google.com/search?q=("is"+or+"whether"+or+"check"+or+"assert"+or+"detect")+("hard+link"+or+"hardlink")+autohotkey&newwindow=1&safe=strict&sxsrf=ALeKk031n43qSrYP39VTNax_ulny-7xt6A%3A1623676506766&ei=WlbHYIScLsjn-QbIyJvgDg&oq=("is"+or+"whether"+or+"check"+or+"assert"+or+"detect")+("hard+link"+or+"hardlink")+autohotkey&gs_lcp=Cgdnd3Mtd2l6EANQkvkDWJKoBWCOsAVoCnAAeAGAAe8EiAGRN5IBDTAuMTEuMTIuMS4yLjKYAQCgAQGgAQKqAQdnd3Mtd2l6wAEB&sclient=gws-wiz&ved=0ahUKEwiEsamrmpfxAhXIc94KHUjkBuwQ4dUDCA4&uact=5)
看着严谨，但结果不如如下。

[is hard link autohotkey - Google 搜索](https://www.google.com/search?q=is+hard+link+autohotkey&newwindow=1&safe=strict&sxsrf=ALeKk01qAXbv9FE2ses6Lqhdnwyc7L3MPA%3A1623676370136&ei=0lXHYKbPB9XW-QaeuJWYAw&oq=is+hard+link+autohotkey&gs_lcp=Cgdnd3Mtd2l6EAM6BggAEAgQHjoFCCEQoAE6BwghEAoQoAFQpwhYtB1g3B9oAHAAeACAAb4GiAGJGpIBCzAuMi41LjMuNi0xmAEAoAEBqgEHZ3dzLXdpesABAQ&sclient=gws-wiz&ved=0ahUKEwimgJbqmZfxAhVVa94KHR5cBTMQ4dUDCA4&uact=5)

[(30) [Function\] FilesHardLinked() - Detect if two files are hardlinks (links pointing to the same file) - AutoHotkey Community](https://www.autohotkey.com/boards/viewtopic.php?t=69169)
不是很相关，其需指定待比较的两文件，而非期望的，检测任意（一个）文件。

[(is or whether or check or assert or detect) ("hard link" or "hardlink") - Google 搜索](https://www.google.com/search?q=(is+or+whether+or+check+or+assert+or+detect)+("hard+link"+or+"hardlink")+&newwindow=1&safe=strict&sxsrf=ALeKk031n43qSrYP39VTNax_ulny-7xt6A%3A1623676506766&ei=WlbHYIScLsjn-QbIyJvgDg&oq=(is+or+whether+or+check+or+assert+or+detect)+("hard+link"+or+"hardlink")+&gs_lcp=Cgdnd3Mtd2l6EAwyBwgjEK4CECc6CggjEK4CELADECdQyApYyApgkxJoAnAAeACAAd4BiAG5A5IBAzItMpgBAKABAaoBB2d3cy13aXrIAQHAAQE&sclient=gws-wiz&ved=0ahUKEwiEsamrmpfxAhXIc94KHUjkBuwQ4dUDCA4)
[("is" or "whether" or "check" or "assert" or "detect") ("hard link" or "hardlink") - Google 搜索](https://www.google.com/search?q=("is"+or+"whether"+or+"check"+or+"assert"+or+"detect")+("hard+link"+or+"hardlink")&newwindow=1&safe=strict&sxsrf=ALeKk00Lb9EnPIMcMRq8DFvfC7gCIryVog%3A1623677192900&ei=CFnHYIyzNtT4wAOBi77wBg&oq=("is"+or+"whether"+or+"check"+or+"assert"+or+"detect")+("hard+link"+or+"hardlink")&gs_lcp=Cgdnd3Mtd2l6EAMyBwgjEK4CECc6CggjEK4CELADECdQihxYxyFglSNoAXAAeACAAZUCiAGdBZIBBTAuMi4xmAEAoAEBqgEHZ3dzLXdpesgBAcABAQ&sclient=gws-wiz&ved=0ahUKEwiM17_ynJfxAhVUPHAKHYGFD24Q4dUDCA4&uact=5)
移除<u>autohotkey</u>。

[("query" OR "enum" or "list") ("hard link" OR "hardlink") autohotkey - Google 搜索](https://www.google.com/search?q=("query"+OR+"enum"+or+"list")+("hard+link"+OR+"hardlink")+autohotkey&newwindow=1&safe=strict&sxsrf=ALeKk003RM9Qn12rTtkeuUJgL0sOdaKhow%3A1623678214743&ei=Bl3HYOjjLOWS1e8P4-OO2AM&oq=("query"+OR+"enum"+or+"list")+("hard+link"+OR+"hardlink")+autohotkey&gs_lcp=Cgdnd3Mtd2l6EAM6BwgjEK4CECc6BwghEAoQoAFQ8AlYuyVghydoA3AAeACAAYcEiAHZG5IBCzAuMy43LjEuMC4ymAEAoAEBqgEHZ3dzLXdpesABAQ&sclient=gws-wiz&ved=0ahUKEwjo_t_ZoJfxAhVlSfUHHeOxAzsQ4dUDCA4&uact=5)
移除<u>autohotkey</u>，结果会多不少。

[[AHK_L\] ListMFTfiles: NTFS Instant File Search - Scripts and Functions - AutoHotkey Community](https://autohotkey.com/board/topic/79420-ahk-l-listmftfiles-ntfs-instant-file-search/)

[python 3.x - Quick way to enumerate all hardlinks in python3 - Stack Overflow](https://stackoverflow.com/questions/56589633/quick-way-to-enumerate-all-hardlinks-in-python3)

> `fsutil hardlink list <path>`
>
> On Windows, enumeration of hardlinks to any given file is facilitated by the [FindFirstFileName](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilenamew), [FindNextFileName](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findnextfilenamew), and [FindClose](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findclose) trio.

[batch file - Listing non symbolic link on Windows - Stack Overflow](https://stackoverflow.com/questions/39213595/listing-non-symbolic-link-on-windows)

#### 文件处理

[FindClose function (fileapi.h) - Win32 apps | Microsoft Docs](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findclose)
全，参见相关，如：
[FindFirstFileNameW function (fileapi.h) - Win32 apps | Microsoft Docs](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilenamew)
[FindNextFileNameW function (fileapi.h) - Win32 apps | Microsoft Docs](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findnextfilenamew)

[FindFirstFileNamew FindClose autohotkey - Google 搜索](https://www.google.com/search?q=FindFirstFileName+FindClose+autohotkey&newwindow=1&safe=strict&sxsrf=ALeKk01471wJPcTwdZs-3w4pFXj0ovdy2Q%3A1623680057089&ei=OWTHYO_qBNSi-QawjoroAg&oq=FindFirstFileName+FindClose+autohotkey&gs_lcp=Cgdnd3Mtd2l6EANQvcECWPXDAmCLyAJoAXAAeACAAe4BiAGaBZIBAzItM5gBAKABAqABAaoBB2d3cy13aXrAAQE&sclient=gws-wiz&ved=0ahUKEwiv65_Ip5fxAhVUUd4KHTCHAi0Q4dUDCA4&uact=5)
不可<u>FindFirstFileName</u>（无W）。

[(28) [a123\] showlink.ahk — navigate to hardlinks of file - AutoHotkey Community](https://www.autohotkey.com/boards/viewtopic.php?t=86940&p=382043)

